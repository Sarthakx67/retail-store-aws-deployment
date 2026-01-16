# -------- BUILD STAGE --------
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy go mod files first (for caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build static binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o app

# -------- RUNTIME STAGE --------
FROM gcr.io/distroless/base-debian12

WORKDIR /app

COPY --from=builder /app/app .

USER nonroot:nonroot

EXPOSE 8080

CMD ["./app"]
