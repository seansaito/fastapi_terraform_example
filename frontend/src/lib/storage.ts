const TOKEN_KEY = 'azure-todo-token'

const isBrowser = typeof window !== 'undefined'

export const tokenStorage = {
  get(): string | null {
    if (!isBrowser) return null
    return window.localStorage.getItem(TOKEN_KEY)
  },
  set(token: string) {
    if (!isBrowser) return
    window.localStorage.setItem(TOKEN_KEY, token)
  },
  clear() {
    if (!isBrowser) return
    window.localStorage.removeItem(TOKEN_KEY)
  },
}
