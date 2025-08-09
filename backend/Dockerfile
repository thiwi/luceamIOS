FROM node:20-alpine AS builder
ENV NPM_CONFIG_LEGACY_PEER_DEPS=true

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

FROM node:20-alpine
ENV NPM_CONFIG_LEGACY_PEER_DEPS=true

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev

COPY --from=builder /app/dist ./dist

CMD ["node", "dist/main"]
