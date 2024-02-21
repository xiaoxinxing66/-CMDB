
FROM golang:1.22-alpine as builder

LABEL maintainer="Sivan"

ENV GOPROXY https://goproxy.cn/

WORKDIR /go/release
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk update && apk add tzdata

COPY ./go.mod ./go.mod
RUN go mod download
COPY . .
RUN pwd && ls

RUN go build -ldflags="-s -w" -o fiy main.go

FROM alpine

WORKDIR /app

COPY --from=builder /go/release/fiy ./fiy
COPY --from=builder /go/release/config ./config
COPY --from=builder /go/release/static ./static
COPY --from=builder /go/release/template ./template
COPY --from=builder /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

EXPOSE 8000

CMD ["./fiy","server","-c", "config/settings.yml"]

