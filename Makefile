.PHONY: run build builder

-include .env
ROOT_DIR:=$(abspath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
DIST_DIR=$(ROOT_DIR)/dist
BINARY:=$(DIST_DIR)/$(PROJECTNAME)$(shell go env GOEXE)
GITTAG:=$(shell git describe --tags || echo 'unknown')
GITVERSION:=$(shell git rev-parse HEAD || echo ${GITHUB_SHA})
PACKAGES:=$(shell go list ./... | grep -v /vendor/)
VETPACKAGES=`go list ./... | grep -v /vendor/ | grep -v /examples/`
GOFILES=`find . -name "*.go" -type f -not -path "./vendor/*"`
GOLANG_VER:=$(shell go env GOVERSION)
BUILD_TIME=`date +%FT%T%z`
BUILD_USER=`echo "BID/${CI_BUILD_ID:-GITHUB_RUN_ID} PID/${CI_PIPELINE_ID:-GITHUB_RUN_NUMBER} NAME/${PROJECTNAME} SLUG/${CI_BUILD_REF_SLUG} USER/${GITLAB_USER_EMAIL:-GITHUB_WORKFLOW_SHA} RUNNER/${CI_RUNNER_DESCRIPTION:-RUNNER_NAME} BUILDER/${GOLANG_VERSION:-GOLANG_VER}"`
BUILD_VERSION=`echo "TAG/${GITTAG} GIT/${GITVERSION} NAME/${PROJECTNAME} CCT/${CI_COMMIT_TAG}"`
LDFLAGS=-ldflags "-s -w -X 'main.projectName=$(PROJECTNAME)' -X 'main.gitVersion=${GITVERSION}' -X 'main.buildTime=${BUILD_TIME}' -X 'main.buildVersion=${BUILD_VERSION}' -X 'main.buildUser=${BUILD_USER}' -X 'main.version=$(VERSION)'"
GOBUILD=go build -trimpath
TSGOSRC=$(abspath $(realpath $(shell go env GOROOT)))

all: run

build:
	@echo " > Building binary(windows)..."
	env CGO_ENABLED=1 GOOS=windows GOARCH=amd64 ${GOBUILD} ${LDFLAGS} -race -o ${BINARY} ./cmd/app
	# @echo " > Building binary(linux)..."
	# @env CGO_ENABLED=1 GOOS=linux GOARCH=amd64 ${GOBUILD} ${LDFLAGS} -race -o $(DIST_DIR)/$(PROJECTNAME) ./cmd/app

builder:
	@#echo " > Building binary..."
	env CGO_ENABLED=0 ${GOBUILD} ${LDFLAGS} -o ${BINARY} ./cmd/app
	@echo " > Compress binary..."
	@upx $(BINARY)

run:  build
	@echo " > exec..."
	${BINARY} ${HOST_OPT}

debug: fmt
	@echo " > Install debug..."
	@go install github.com/go-delve/delve/cmd/dlv@latest
	@echo " > Building ${BINARY}..."
	@${GOBUILD} -gcflags "all=-N -l" -o ${BINARY} ./cmd/app
	# @dlv-dap --headless --log --listen=:6353 --api-version=2 exec ${BINARY}

list:
	@echo " > list..."
	@echo ${PACKAGES}
	@echo ${VETPACKAGES}
	@echo ${GOFILES}

fmt:
	@echo " > gofmt..."
	@goimports -local github.com -local ${PROJECTNAME} -w .
	@go fmt ./...

check: fmt
	@golint "-set_exit_status" ${GOFILES}
	@go vet ${GOFILES}

test:
	@go test -cpu=1,2,4 -v -tags integration all

up: fmt vet tidy
	@echo " > go update..."
	@go get -u -v ./cmd/app

tidy:
	@echo " > Tidying mod file..."
	@go mod tidy


vet:
	@echo " > go vet..."
	@go vet $(VETPACKAGES)

install:
	@go install mvdan.cc/garble@latest
	@go install golang.org/x/tools/cmd/goimports@latest
	# @https://github.com/boy-hack/go-strip

clean:
	@echo " > clean..."
	@if [ -f ${BINARY} ] ; then rm ${BINARY} ; fi

