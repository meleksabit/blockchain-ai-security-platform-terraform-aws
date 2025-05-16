# Stage 1: Build the application
FROM golang:1.24 AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o anomaly-detector

# Stage 2: Copy the application to the runtime image
FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/anomaly-detector .

EXPOSE 8082

CMD ["./anomaly-detector"]
