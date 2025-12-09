FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
RUN npx prisma generate

FROM node:18-alpine
WORKDIR /app
# Librairies nécessaires pour Prisma
RUN apk add --no-cache openssl libgcc libstdc++ bash
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/src ./src
COPY --from=builder /app/seed ./seed  
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "src/index.js"]
