# Project directories
CWD := $(abspath $(shell pwd))
SRC := $(CWD)/src
OUT := $(CWD)/out
FONTS := $(CWD)/fonts
SRC_DIRS := $(filter-out $(SRC)/checklists.egg-info, $(wildcard $(SRC)/*))

# Define one output file name for each directory in src
TARGETS := $(addsuffix .pdf, $(patsubst $(SRC)/%,$(OUT)/%,$(SRC_DIRS)))

# Font files
FONT_FILES := $(FONTS)/B612-Regular.ttf $(FONTS)/B612-Bold.ttf $(FONTS)/B612-Italic.ttf $(FONTS)/B612-BoldItalic.ttf

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

# Use system pandoc but run in uv environment to access weasyprint
PANDOC := uv run --with-editable . pandoc
PANDOC_OPTIONS=--defaults ./pandoc/defaults.yaml --metadata title="" --metadata author=""

.PHONY: all list clean setup fonts
.SILENT: all list clean setup fonts

# Ensure dependencies are installed
setup:
	@echo "Installing dependencies with uv..."
	@uv sync

# Download fonts
fonts: $(FONT_FILES)

$(FONT_FILES): | $(FONTS)
	@echo "Downloading fonts..."
	@uv run python scripts/download_fonts.py

$(FONTS):
	@mkdir -p $@

all: setup fonts $(TARGETS)

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
