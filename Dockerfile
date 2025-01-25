FROM golang:alpine AS builder
ARG TARGETPLATFORM
RUN echo "I'm building for $TARGETPLATFORM"

RUN apk add --no-cache gzip make g++ git upx

WORKDIR /tmp/go-app

ADD go.mod go.sum ./
RUN go mod download

ADD . .
RUN make builder

FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /tmp/go-app/dist/ikuai-exporter /app/ikuai-exporter
WORKDIR /app
ENTRYPOINT [ "/app/ikuai-exporter" ]
