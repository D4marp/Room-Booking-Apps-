.PHONY: help build run dev test clean install-deps

help:
	@echo "Bookify Rooms Backend - Makefile Commands"
	@echo "========================================="
	@echo "make install-deps    - Install Go dependencies"
	@echo "make build           - Build the backend"
	@echo "make run             - Run the backend"
	@echo "make dev             - Run in development mode with hot reload"
	@echo "make test            - Run tests"
	@echo "make clean           - Clean build artifacts"
	@echo "make docker-build    - Build Docker image"
	@echo "make docker-run      - Run Docker container"

install-deps:
	@echo "Installing dependencies..."
	go mod download
	go mod tidy

build:
	@echo "Building backend..."
	go build -o bin/main ./cmd/main.go

run: build
	@echo "Running backend..."
	./bin/main

dev:
	@echo "Running in development mode..."
	go run ./cmd/main.go

test:
	@echo "Running tests..."
	go test -v ./...

clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	go clean

docker-build:
	@echo "Building Docker image..."
	docker build -t bookify-rooms-backend:latest .

docker-run: docker-build
	@echo "Running Docker container..."
	docker run -p 8080:8080 bookify-rooms-backend:latest
