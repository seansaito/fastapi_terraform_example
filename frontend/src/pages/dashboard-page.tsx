import { useCallback } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { TodoForm } from '@/features/todos/components/todo-form'
import { TodoList } from '@/features/todos/components/todo-list'
import { useTodos } from '@/features/todos/hooks'

export const DashboardPage = () => {
  const { listQuery, createTodo, updateTodo, deleteTodo } = useTodos()

  const handleToggle = useCallback(
    async (todo: { id: string; is_completed: boolean }) => {
      await updateTodo(todo.id, { is_completed: !todo.is_completed })
    },
    [updateTodo]
  )

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Create a new todo</CardTitle>
        </CardHeader>
        <CardContent>
          <TodoForm onSubmit={createTodo} />
        </CardContent>
      </Card>

      <div>
        <h2 className="mb-2 text-lg font-semibold">Your tasks</h2>
        <TodoList
          todos={listQuery.data ?? []}
          isLoading={listQuery.isLoading}
          onToggle={handleToggle}
          onDelete={(todo) => deleteTodo(todo.id)}
        />
      </div>
    </div>
  )
}
