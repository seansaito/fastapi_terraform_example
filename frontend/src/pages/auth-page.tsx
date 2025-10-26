import { Navigate } from 'react-router-dom'

import { AuthForm } from '@/features/auth/components/auth-form'
import { useAuth } from '@/providers/auth-provider'

type Props = {
  mode: 'login' | 'register'
}

export const AuthPage = ({ mode }: Props) => {
  const { status } = useAuth()

  if (status === 'authenticated') {
    return <Navigate to="/" replace />
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/20 px-4 py-12">
      <AuthForm mode={mode} />
    </div>
  )
}
