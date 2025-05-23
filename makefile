# Project directories
CWD := $(abspath $(shell pwd))
SRC := $(CWD)/src
OUT := $(CWD)/out
SRC_DIRS := $(wildcard $(SRC)/*)

# Define one output file name for each directory in src
TARGETS := $(addsuffix .pdf, $(patsubst $(SRC)/%,$(OUT)/%,$(SRC_DIRS)))

# Detect OS and set appropriate paths
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    # macOS
    PANDOC := $(shell which pandoc || echo /opt/homebrew/bin/pandoc)
    RM := /bin/rm -f
else ifeq ($(UNAME_S),Linux)
    # Linux
    PANDOC := $(shell which pandoc || echo /usr/bin/pandoc)
    RM := rm -f
else
    # Windows (MINGW/MSYS/Cygwin)
    PANDOC := $(shell which pandoc.exe || which pandoc || echo pandoc)
    RM := del /f
endif

PANDOC_OPTIONS=--defaults ./pandoc/defaults.yaml --metadata title="" --metadata author=""

.PHONY: all list clean
.SILENT: all list clean

all: $(TARGETS)

list:
	@echo $(TARGETS)

.SECONDEXPANSION:
$(OUT)/%.pdf: $(CWD)/css/checklist.css $$(wildcard $(SRC)/%/*.html) | $(OUT)
	@echo $@
	@$(PANDOC) $(PANDOC_OPTIONS) $(filter-out $<,$^) -o $@

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
