# Step 1: Build the Go application
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code
COPY . .

# Build the Go app
# -ldflags="-w -s" strips debug information and symbols to reduce the binary size
# CGO_ENABLED=0 disables Cgo to create a statically linked binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /main .

# Step 2: Create a small, final image
FROM alpine:latest

WORKDIR /app

# Copy the pre-built binary from the builder stage
COPY --from=builder /main .

# Copy .env.example, in a real scenario, env vars would be injected by the cloud provider
# COPY .env.example .env

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["/app/main"]