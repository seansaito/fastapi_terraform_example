import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'

import { todosApi } from '@/features/todos/api'
import type { TodoCreate, TodoUpdate } from '@/features/todos/types'

const TODOS_KEY = ['todos'] as const

export const useTodos = () => {
  const queryClient = useQueryClient()

  const listQuery = useQuery({
    queryKey: TODOS_KEY,
    queryFn: todosApi.list,
  })

  const createMutation = useMutation({
    mutationFn: todosApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: TODOS_KEY })
      toast.success('Todo created')
    },
    onError: () => toast.error('Unable to create todo'),
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: TodoUpdate }) => todosApi.update(id, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: TODOS_KEY })
      toast.success('Todo updated')
    },
    onError: () => toast.error('Unable to update todo'),
  })

  const deleteMutation = useMutation({
    mutationFn: (id: string) => todosApi.remove(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: TODOS_KEY })
      toast.success('Todo removed')
    },
    onError: () => toast.error('Unable to delete todo'),
  })

  const createTodo = (payload: TodoCreate) => createMutation.mutateAsync(payload)
  const updateTodo = (id: string, payload: TodoUpdate) => updateMutation.mutateAsync({ id, payload })
  const deleteTodo = (id: string) => deleteMutation.mutateAsync(id)

  return {
    listQuery,
    createTodo,
    updateTodo,
    deleteTodo,
    isMutating: createMutation.isPending || updateMutation.isPending || deleteMutation.isPending,
  }
}
