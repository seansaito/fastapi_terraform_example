/* eslint-disable react-refresh/only-export-components */
import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react'
import { authApi, type LoginPayload, type RegisterPayload, type User } from '@/features/auth/api'
import { tokenStorage } from '@/lib/storage'
import { setAuthTokenGetter, setUnauthorizedHandler } from '@/lib/api'
import { toast } from 'sonner'

export type AuthStatus = 'loading' | 'authenticated' | 'unauthenticated'

type AuthContextValue = {
  user: User | null
  token: string | null
  status: AuthStatus
  login: (payload: LoginPayload) => Promise<void>
  register: (payload: RegisterPayload) => Promise<void>
  logout: () => void
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined)

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [token, setToken] = useState<string | null>(() => tokenStorage.get())
  const [user, setUser] = useState<User | null>(null)
  const [status, setStatus] = useState<AuthStatus>(() => (token ? 'loading' : 'unauthenticated'))

  useEffect(() => {
    setAuthTokenGetter(() => token)
    setUnauthorizedHandler(() => {
      setToken(null)
      setUser(null)
      setStatus('unauthenticated')
    })
    if (token) {
      tokenStorage.set(token)
    } else {
      tokenStorage.clear()
    }
  }, [token])

  useEffect(() => {
    let cancelled = false
    const bootstrap = async () => {
      if (!token) {
        setStatus('unauthenticated')
        setUser(null)
        return
      }
      setStatus('loading')
      try {
        const profile = await authApi.me()
        if (!cancelled) {
          setUser(profile)
          setStatus('authenticated')
        }
      } catch {
        if (!cancelled) {
          toast.error('Session expired, please sign in again')
          setToken(null)
          setStatus('unauthenticated')
        }
      }
    }

    bootstrap()
    return () => {
      cancelled = true
    }
  }, [token])

  const login = useCallback(async (payload: LoginPayload) => {
    setStatus('loading')
    const { access_token } = await authApi.login(payload)
    setToken(access_token)
  }, [])

  const register = useCallback(
    async (payload: RegisterPayload) => {
      setStatus('loading')
      await authApi.register(payload)
      await login({ email: payload.email, password: payload.password })
    },
    [login]
  )

  const logout = useCallback(() => {
    setToken(null)
    setUser(null)
    setStatus('unauthenticated')
  }, [])

  const value = useMemo<AuthContextValue>(
    () => ({ user, token, status, login, register, logout }),
    [login, logout, register, status, token, user]
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export const useAuth = () => {
  const ctx = useContext(AuthContext)
  if (!ctx) {
    throw new Error('useAuth must be used inside <AuthProvider>')
  }
  return ctx
}
