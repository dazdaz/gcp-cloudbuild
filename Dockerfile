FROM golang:alpine AS build-env
WORKDIR /buildapp
ADD . /buildapp
RUN cd /buildapp && go build -o exapp

FROM alpine:latest
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
WORKDIR /app
COPY --from=0 /buildapp/exapp /app

EXPOSE 8000
CMD ["./exapp"]
