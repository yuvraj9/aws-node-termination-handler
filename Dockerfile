# Build the manager binary
FROM golang:1.13 as builder

## GOLANG env
ARG GOPROXY="https://proxy.golang.org,direct"
ARG GO111MODULE="on"
ARG CGO_ENABLED=0
ARG GOOS=linux 
ARG GOARCH=amd64 

# Copy go.mod and download dependencies
WORKDIR /node-termination-handler
COPY go.mod .
COPY go.sum .
RUN go mod download

# Build
COPY . .
RUN go build -a -v -o handler /node-termination-handler/cmd
# In case the target is build for testing:
# $ docker build  --target=builder -t test .
ENTRYPOINT ["/node-termination-handler/handler"]

# Copy the controller-manager into a thin image
FROM amazonlinux:2 as amazonlinux
FROM scratch
WORKDIR /
COPY --from=builder /node-termination-handler/handler .
COPY --from=amazonlinux /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/
COPY THIRD_PARTY_LICENSES .
ENTRYPOINT ["/handler"]
