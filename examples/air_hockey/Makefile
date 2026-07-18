CRYSTAL ?= crystal
SHARDS ?= shards

CRFLAGS ?= -Dpreview_mt -Dexecution_context
SOURCE = src/air_hockey.cr
TARGET = bin/air_hockey
TARGET_DIR = bin
RELEASE_FLAGS =
ifdef release
RELEASE_FLAGS = --release
endif

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
	mkdir -p $(TARGET_DIR)
	$(CRYSTAL) build $(RELEASE_FLAGS) $(CRFLAGS) $(SOURCE) -o $(TARGET)

run: build
	./$(TARGET)

clean:
	rm -f $(TARGET)
