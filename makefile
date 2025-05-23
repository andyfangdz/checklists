# Project directories
CWD := $(abspath $(shell pwd))
SRC := $(CWD)/src
OUT := $(CWD)/out
SRC_DIRS := $(wildcard $(SRC)/*)

# Define one output file name for each directory in src
TARGETS := $(addsuffix .pdf, $(patsubst $(SRC)/%,$(OUT)/%,$(SRC_DIRS)))

# External directories
PANDOC=/opt/homebrew/bin/pandoc
PANDOC_OPTIONS=--defaults ./pandoc/defaults.yaml --metadata title="" --metadata author=""
RM=/bin/rm -f

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
	@mkdir -p $@

clean:
	- $(RM) $(TARGETS)
