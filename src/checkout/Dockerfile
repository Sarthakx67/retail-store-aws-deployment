FROM node:20-alpine

WORKDIR /app

COPY package.json yarn.lock ./

RUN corepack enable && yarn install --frozen-lockfile

COPY . .

# IMPORTANT: start backend, NOT serve:dev
CMD ["yarn", "start"]
