FROM golang:1.24 AS builder

WORKDIR /go/src/hello
COPY ./main.go /go/src/hello

RUN go build -o /usr/local/bin/hello ./main.go && chmod +x /usr/local/bin/hello

CMD ["/usr/local/bin/hello"]
