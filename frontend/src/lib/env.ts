const fallbackUrl = 'http://localhost:8000'

export const env = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL?.toString() || fallbackUrl,
}
