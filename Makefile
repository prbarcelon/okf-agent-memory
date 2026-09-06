.PHONY: all build test check validate validate-examples validate-all fmt vet lint vuln clean help

BIN := bin/okf
BUNDLE := knowledge
VERSION ?= dev
COMMIT ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "none")
DATE ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "unknown")

LDFLAGS := -X main.Version=$(VERSION) -X main.Commit=$(COMMIT) -X main.Date=$(DATE)

all: help

build:
	@mkdir -p bin
	@go build -ldflags="$(LDFLAGS)" -o $(BIN) ./cmd/okf

install:
	go install -ldflags="$(LDFLAGS)" ./cmd/okf

test:
	@go test -v ./pkg/okf/...

fmt:
	@gofumpt -w -extra .

vet:
	@go vet ./...

lint:
	@which golangci-lint > /dev/null && golangci-lint run ./... || go vet ./...

vuln:
	@govulncheck ./...

validate: build
	@$(BIN) validate $(BUNDLE) --strict --drift

validate-examples: build
	@$(BIN) validate examples/software --strict
	@$(BIN) validate examples/coaching --strict
	@$(BIN) validate examples/books --strict

validate-all: validate validate-examples
check: vet test validate validate-examples

clean:
	@rm -rf bin

help:
	@echo "OKF Agent Memory Makefile"
	@echo "  make build             Compile bin/okf executable"
	@echo "  make install           Install bin/okf to \$$GOPATH/bin"
	@echo "  make test              Run Go unit tests"
	@echo "  make validate-all      Validate project and example memory bundles"
	@echo "  make clean             Remove build artifacts"
