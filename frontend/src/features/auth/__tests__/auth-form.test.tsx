import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'

import { AuthForm } from '@/features/auth/components/auth-form'
vi.mock('@/providers/auth-provider', () => ({
  useAuth: () => ({
    status: 'unauthenticated',
    login: vi.fn(),
    register: vi.fn(),
  }),
}))

describe('AuthForm', () => {
  it('validates required fields for registration', async () => {
    const user = userEvent.setup()
    render(
      <MemoryRouter>
        <AuthForm mode="register" />
      </MemoryRouter>
    )

    await user.click(screen.getByRole('button', { name: /create account/i }))

    expect(await screen.findByText(/your name is required/i)).toBeInTheDocument()
  })
})
