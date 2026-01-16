# ---------- BUILD STAGE ----------
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install build dependencies for SQLite
RUN apk add --no-cache gcc musl-dev sqlite-dev

# Dependency caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build WITH CGO ENABLED
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -o app

# ---------- RUNTIME STAGE ----------
FROM alpine:3.20

WORKDIR /app

# Install runtime SQLite libs
RUN apk add --no-cache sqlite-libs ca-certificates

COPY --from=builder /app/app .

EXPOSE 8080

CMD ["./app"]
