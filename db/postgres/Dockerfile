FROM golang:1.14 AS stage-01

COPY go.mod /app/go.mod
COPY go.sum /app/go.sum

WORKDIR /app
RUN unset GOPATH && go mod tidy && go mod download

FROM stage-01 AS stage-02
COPY main.go /app/main.go
WORKDIR /app
RUN unset GOPATH && go build -o ./main .

FROM centos:8
RUN yum update -y && yum install curl -y

COPY --from=stage-02 /app/main /app/main
COPY migrations/ /app/migrations

WORKDIR /app
ENTRYPOINT ["./main"]
