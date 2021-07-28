FROM public.ecr.aws/bitnami/golang:1.15 AS stage-01

COPY go.mod /app/go.mod
COPY go.sum /app/go.sum

WORKDIR /app
RUN unset GOPATH && go mod tidy && go mod download

FROM stage-01 AS stage-02
COPY main.go /app/main.go
COPY keycloak.go /app/keycloak.go
WORKDIR /app
RUN unset GOPATH && CGO_ENABLED=0 go build -o ./main .

FROM public.ecr.aws/micahhausler/alpine:3.14.0
RUN apk -U upgrade

RUN addgroup -S migrator --gid 1000 && adduser -S migrator --uid 1000 -G migrator

USER 1000

COPY --from=stage-02 /app/main /app/main
COPY migrations /app/migrations

WORKDIR /app
ENTRYPOINT ["./main"]
