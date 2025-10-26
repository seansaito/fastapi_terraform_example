FROM node:20-alpine

WORKDIR /app

RUN corepack enable

COPY package.json ./
COPY tsconfig*.json ./
COPY vite.config.ts ./
COPY vitest.config.ts ./
COPY tailwind.config.cjs ./
COPY postcss.config.js ./
COPY pnpm-lock.yaml ./

RUN pnpm install

COPY . .

EXPOSE 5173

CMD ["pnpm", "dev", "--host", "0.0.0.0", "--port", "5173"]
