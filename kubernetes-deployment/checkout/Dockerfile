FROM node:20
WORKDIR /app
COPY . .
RUN corepack enable && yarn install
CMD ["yarn", "serve:dev"]