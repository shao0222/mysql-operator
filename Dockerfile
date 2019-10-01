###############################################################################
#  Build the mysql-oerator related binaries
###############################################################################
FROM golang:1.11.2 as builder

# Copy in the go src
WORKDIR /go/src/github.com/presslabs/mysql-operator
COPY pkg/    pkg/
COPY cmd/    cmd/
COPY vendor/ vendor/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o mysql-operator github.com/presslabs/mysql-operator/cmd/mysql-operator
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o mysql-operator-sidecar github.com/presslabs/mysql-operator/cmd/mysql-operator-sidecar
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o orc-helper github.com/presslabs/mysql-operator/cmd/orc-helper

FROM alpine:3.9 as zoneinfo
RUN apk --no-cache add tzdata

###############################################################################
#  Docker image for operator
###############################################################################
FROM scratch

ENV TZ Asia/Shanghai

# Copy the mysql-operator into its own image
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /go/src/github.com/presslabs/mysql-operator/mysql-operator /mysql-operator
COPY --from=zoneinfo /usr/share/zoneinfo /usr/share/zoneinfo

ENTRYPOINT ["/mysql-operator"]
