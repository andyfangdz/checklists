# Project directories
CWD := $(abspath $(shell pwd))
SRC := $(CWD)/src
OUT := $(CWD)/out
SRC_DIRS := $(filter-out $(SRC)/checklists.egg-info, $(wildcard $(SRC)/*))

# Define one output file name for each directory in src
TARGETS := $(addsuffix .pdf, $(patsubst $(SRC)/%,$(OUT)/%,$(SRC_DIRS)))

# Detect OS and set appropriate paths
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    # macOS
    RM := /bin/rm -f
else ifeq ($(UNAME_S),Linux)
    # Linux
    RM := rm -f
else
    # Windows (MINGW/MSYS/Cygwin)
    RM := del /f
endif

# Use system pandoc but ensure weasyprint is available through uv
PANDOC := pandoc
PANDOC_OPTIONS=--defaults ./pandoc/defaults.yaml --metadata title="" --metadata author=""

.PHONY: all list clean setup
.SILENT: all list clean setup

# Ensure dependencies are installed
setup:
	@echo "Installing dependencies with uv..."
	@uv sync

all: setup $(TARGETS)

list:
	@echo $(TARGETS)

.SECONDEXPANSION:
$(OUT)/%.pdf: $(CWD)/css/checklist.css $$(wildcard $(SRC)/%/*.html) | $(OUT)
	@echo $@
	@uv run $(PANDOC) $(PANDOC_OPTIONS) $(filter-out $<,$^) -o $@

$(OUT):
ifeq ($(UNAME_S),$(filter $(UNAME_S),MINGW32 MINGW64 MSYS CYGWIN))
	@if not exist "$(OUT)" mkdir "$(OUT)"
else
	@mkdir -p $@
endif

clean:
ifeq ($(UNAME_S),$(filter $(UNAME_S),MINGW32 MINGW64 MSYS CYGWIN))
	- $(foreach target,$(TARGETS),$(RM) "$(target)" 2>nul &)
else
	- $(RM) $(TARGETS)
endif
