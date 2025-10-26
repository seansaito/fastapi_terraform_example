import { v4 as uuid } from 'uuid'

const requestId = uuid()

export const getRequestId = () => requestId
