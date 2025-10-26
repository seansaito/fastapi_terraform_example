import { BrowserRouter, Navigate, Outlet, Route, Routes } from 'react-router-dom'

import { AppShell } from '@/components/layout/app-shell'
import { FullscreenLoader } from '@/components/loader'
import { AppProviders } from '@/providers/app-providers'
import { useAuth } from '@/providers/auth-provider'
import { DashboardPage } from '@/pages/dashboard-page'
import { SettingsPage } from '@/pages/settings-page'
import { AuthPage } from '@/pages/auth-page'

const ProtectedLayout = () => {
  const { status } = useAuth()

  if (status === 'loading') {
    return <FullscreenLoader />
  }

  if (status !== 'authenticated') {
    return <Navigate to="/login" replace />
  }

  return (
    <AppShell>
      <Outlet />
    </AppShell>
  )
}

const AppRoutes = () => (
  <Routes>
    <Route path="/login" element={<AuthPage mode="login" />} />
    <Route path="/register" element={<AuthPage mode="register" />} />
    <Route element={<ProtectedLayout />}>
      <Route path="/" element={<DashboardPage />} />
      <Route path="/settings" element={<SettingsPage />} />
    </Route>
    <Route path="*" element={<Navigate to="/" replace />} />
  </Routes>
)

export const App = () => (
  <AppProviders>
    <BrowserRouter>
      <AppRoutes />
    </BrowserRouter>
  </AppProviders>
)
