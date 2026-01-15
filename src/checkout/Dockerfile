# Stage 1: Build Angular
FROM node:20-alpine AS build

WORKDIR /app

# Copy only dependency files first (better caching)
COPY package.json yarn.lock ./

RUN corepack enable && yarn install --frozen-lockfile

# Copy rest of the source code
COPY . .

# Build Angular (creates /app/dist)
RUN yarn build


# yarn serve:dev --> “I am developing”
# yarn build --> “I am finished developing”

# Stage 2: Run with Nginx
FROM nginx:alpine

# Remove default nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
