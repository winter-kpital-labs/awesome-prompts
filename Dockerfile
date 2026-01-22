# --- build ---
FROM node:24-bookworm-slim AS builder
WORKDIR /app

# deps
COPY package*.json ./
COPY prisma ./prisma
RUN npm ci

# build
COPY . .
RUN npx prisma generate
RUN npm run build

# --- run ---
FROM node:24-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production

# copia lo necesario para correr Next
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.* ./ 2>/dev/null || true

EXPOSE 3000
CMD ["npm", "run", "start"]
