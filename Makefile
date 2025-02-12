NAME = docker2exe
OUTPUT = dist
VERSION = v0.2.1
SOURCES = $(wildcard *.go)
TARGETS = darwin/amd64 darwin/arm64 linux/amd64 windows/amd64

OS = $(shell go env GOOS)
ARCH = $(shell go env GOARCH)

# Detect Windows
ifeq ($(OS),Windows_NT)
    # PowerShell command wrapper
    SET_ENV = powershell -Command "$$env:GOOS='$(1)'; $$env:GOARCH='$(2)'; 
    MKDIR = powershell -Command "New-Item -ItemType Directory -Force -Path"
else
    # Unix command wrapper
    SET_ENV = GOOS=$(1) GOARCH=$(2)
    MKDIR = mkdir -p
endif

os = $(word 1, $(subst /, ,$@))
arch = $(word 2, $(subst /, ,$@))

.PHONY: all
all: $(TARGETS)

.PHONY: clean
clean:
	$(RM) -rf dist

.PHONY: test
test: all
	dist/docker2exe-$(OS)-$(ARCH) --name test --image alpine
	dist/test-$(OS)-$(ARCH) echo OK
	dist/docker2exe-$(OS)-$(ARCH) --name test-embed --image alpine --embed
	dist/test-embed-$(OS)-$(ARCH) echo OK

.PHONY: release
release: clean all
	gh release create $(VERSION) dist/docker2exe-* --generate-notes

$(OUTPUT):
	$(MKDIR) $(OUTPUT)

$(TARGETS): $(SOURCES) $(OUTPUT)
	$(call SET_ENV,$(os),$(arch)) go build -o "$(OUTPUT)/$(NAME)-$(os)-$(arch)"
