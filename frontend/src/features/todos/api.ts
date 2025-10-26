import { api } from '@/lib/api'
import type { Todo, TodoCreate, TodoUpdate } from '@/features/todos/types'

export const todosApi = {
  async list(): Promise<Todo[]> {
    const { data } = await api.get<Todo[]>('/todos')
    return data
  },
  async create(payload: TodoCreate): Promise<Todo> {
    const { data } = await api.post<Todo>('/todos', payload)
    return data
  },
  async update(id: string, payload: TodoUpdate): Promise<Todo> {
    const { data } = await api.patch<Todo>(`/todos/${id}`, payload)
    return data
  },
  async remove(id: string): Promise<void> {
    await api.delete(`/todos/${id}`)
  },
}
