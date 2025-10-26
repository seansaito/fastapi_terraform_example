export type Todo = {
  id: string
  title: string
  description?: string | null
  is_completed: boolean
  created_at: string
  updated_at: string
}

export type TodoCreate = {
  title: string
  description?: string | null
}

export type TodoUpdate = Partial<TodoCreate> & {
  is_completed?: boolean
}
