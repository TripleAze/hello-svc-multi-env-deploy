FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go file
COPY hello-svc/main.go /app/main.go

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o hello-svc main.go

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/hello-svc .

EXPOSE 8080

CMD ["./hello-svc"]
