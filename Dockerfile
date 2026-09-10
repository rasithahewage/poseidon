# syntax = docker/dockerfile:1
FROM golang:1.25 AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o poseidon -v ./cmd/poseidon

FROM debian:bookworm-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /app/poseidon /app/poseidon
COPY --from=build /app/configuration.example.yaml /app/configuration.example.yaml
COPY --from=build /app/configuration.yaml /app/configuration.yaml

EXPOSE 7200

ENTRYPOINT ["/app/poseidon"]
