# Build stage
FROM golang:1.24 AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o blockchain-monitor

# Runtime stage
FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/blockchain-monitor .

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --quiet --tries=1 --spider http://localhost:8081/health || exit 1

CMD ["./blockchain-monitor"]
