import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'

import { TodoList } from '@/features/todos/components/todo-list'

describe('TodoList', () => {
  const baseTodo = {
    id: '1',
    title: 'Learn FastAPI',
    description: 'Build backend',
    is_completed: false,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  }

  it('renders todos and triggers callbacks', async () => {
    const user = userEvent.setup()
    const onToggle = vi.fn().mockResolvedValue(undefined)
    const onDelete = vi.fn().mockResolvedValue(undefined)
    render(<TodoList todos={[baseTodo]} isLoading={false} onToggle={onToggle} onDelete={onDelete} />)

    expect(screen.getByText(/learn fastapi/i)).toBeInTheDocument()

    await user.click(screen.getByText(/learn fastapi/i))
    expect(onToggle).toHaveBeenCalledWith(baseTodo)

    await user.click(screen.getByRole('button', { name: /delete todo/i }))
    expect(onDelete).toHaveBeenCalledWith(baseTodo)
  })
})
