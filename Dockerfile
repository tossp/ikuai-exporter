

FROM golang:alpine as builder
LABEL maintainers="Jakes Lee; Toss Pig"
LABEL description="iKuai exporter"

RUN apk add --no-cache make g++ git upx

WORKDIR /tmp/go-app

ADD go.mod go.sum ./
RUN go mod download

ADD . .
RUN make builder

FROM alpine
RUN apk add ca-certificates
COPY --from=builder /tmp/go-app/dist/ikuai-exporter /app/ikuai-exporter
WORKDIR /app
ENTRYPOINT [ "/app/ikuai-exporter" ]
