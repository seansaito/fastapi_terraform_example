import { api } from '@/lib/api'

export type User = {
  id: string
  email: string
  full_name: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export type RegisterPayload = {
  email: string
  full_name: string
  password: string
}

export type LoginPayload = {
  email: string
  password: string
}

type TokenResponse = {
  access_token: string
  token_type: string
}

export const authApi = {
  async register(payload: RegisterPayload): Promise<User> {
    const { data } = await api.post<User>('/auth/register', payload)
    return data
  },
  async login(payload: LoginPayload): Promise<TokenResponse> {
    const body = new URLSearchParams()
    body.append('username', payload.email)
    body.append('password', payload.password)
    const { data } = await api.post<TokenResponse>('/auth/token', body, {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    })
    return data
  },
  async me(): Promise<User> {
    const { data } = await api.get<User>('/auth/me')
    return data
  },
}
