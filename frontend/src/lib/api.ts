import axios from 'axios'
import { env } from '@/lib/env'
import { getRequestId } from '@/lib/request-id'

let tokenGetter: (() => string | null) | null = null
let unauthorizedHandler: (() => void) | null = null

export const setAuthTokenGetter = (getter: () => string | null) => {
  tokenGetter = getter
}

export const setUnauthorizedHandler = (handler: () => void) => {
  unauthorizedHandler = handler
}

export const api = axios.create({
  baseURL: env.apiBaseUrl,
  timeout: 10_000,
})

api.interceptors.request.use((config) => {
  const token = tokenGetter?.()
  if (token) {
    config.headers = {
      ...config.headers,
      Authorization: `Bearer ${token}`,
    }
  }
  config.headers = {
    'x-request-id': getRequestId(),
    ...config.headers,
  }
  return config
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      unauthorizedHandler?.()
    }
    return Promise.reject(error)
  }
)
