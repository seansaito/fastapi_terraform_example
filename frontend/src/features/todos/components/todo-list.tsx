import { CheckCircle2, Circle, Loader2, Trash2 } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { cn } from '@/lib/utils'
import type { Todo } from '@/features/todos/types'

type Props = {
  todos: Todo[]
  isLoading: boolean
  onToggle: (todo: Todo) => Promise<void>
  onDelete: (todo: Todo) => Promise<void>
}

export const TodoList = ({ todos, isLoading, onToggle, onDelete }: Props) => {
  if (isLoading) {
    return (
      <div className="flex min-h-[200px] items-center justify-center">
        <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
      </div>
    )
  }

  if (todos.length === 0) {
    return (
      <Card className="border-dashed">
        <CardHeader>
          <CardTitle>No todos yet</CardTitle>
          <CardDescription>Create your first task above to get started.</CardDescription>
        </CardHeader>
      </Card>
    )
  }

  return (
    <div className="space-y-3">
      {todos.map((todo) => (
        <Card key={todo.id} className={cn('transition-all', todo.is_completed && 'border-primary/40 bg-primary/5')}>
          <CardContent className="flex items-start justify-between gap-4 py-4">
            <button
              onClick={() => onToggle(todo)}
              className="flex flex-1 items-start gap-3 text-left"
              aria-label={todo.is_completed ? 'Mark todo as incomplete' : 'Mark todo as complete'}
            >
              {todo.is_completed ? <CheckCircle2 className="mt-1 h-5 w-5 text-primary" /> : <Circle className="mt-1 h-5 w-5 text-muted-foreground" />}
              <div>
                <p className={cn('text-base font-medium', todo.is_completed && 'text-muted-foreground line-through')}>{todo.title}</p>
                {todo.description ? <p className="text-sm text-muted-foreground">{todo.description}</p> : null}
              </div>
            </button>
            <Button variant="ghost" size="icon" onClick={() => onDelete(todo)} aria-label="Delete todo">
              <Trash2 className="h-4 w-4" />
            </Button>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
