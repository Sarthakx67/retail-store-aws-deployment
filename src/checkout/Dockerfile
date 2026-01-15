# =========================
# Stage 1: Build
# =========================
FROM node:20-alpine AS build

WORKDIR /app

COPY package.json yarn.lock ./

RUN corepack enable && yarn install --frozen-lockfile

COPY . .

# Compile TypeScript -> JavaScript
RUN yarn build

# =========================
# Stage 2: Runtime
# =========================
FROM node:20-alpine

WORKDIR /app

# Copy only compiled output + deps
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json

# IMPORTANT: NO watch mode
CMD ["node", "dist/main"]
