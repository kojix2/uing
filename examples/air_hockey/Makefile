CRYSTAL ?= crystal
SHARDS ?= shards

CRFLAGS ?= -Dpreview_mt -Dexecution_context
SOURCE = src/air_hockey.cr
TARGET = bin/air_hockey
RELEASE_FLAGS = $(if $(release),--release,)

.PHONY: all help deps build run clean

all: build

help:
	@echo "Air Hockey example"
	@echo ""
	@echo "Targets:"
	@echo "  make build       Build bin/air_hockey"
	@echo "  make run         Build and run the game"
	@echo "  make clean       Remove bin/air_hockey"
	@echo "  make deps        Install shard dependencies"
	@echo ""
	@echo "Options:"
	@echo "  make build release=1   Build with --release"
	@echo "  make run release=1     Run a release build"

deps:
	$(SHARDS) install

build: deps
	$(CRYSTAL) build $(RELEASE_FLAGS) $(CRFLAGS) $(SOURCE) -o $(TARGET)

run: build
	./$(TARGET)

clean:
	rm -f $(TARGET)
