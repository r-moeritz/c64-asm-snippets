# Paths
OBJDIR := build
ASS := 64tass
ASM := ras64.asm
BAS := demo.bas
BIN := $(OBJDIR)/ras64.bin
LAB := $(OBJDIR)/ras64.lab
LST := $(OBJDIR)/ras64.lst
PRG := $(OBJDIR)/demo
D64 := $(OBJDIR)/ras64-demo.d64

# Commands
MKPRG = petcat -w2 -o $@ -- $<
MKBIN = $(ASS) -a -m -L $(LST) -l $(LAB) --vice-labels -o $(BIN) $(ASM)
RM := rm -rf
CP = cp $< $@
MKDIR := mkdir -p
MKD64 = c1541 -format ras64-demo,md d64 $@ -attach $@ $(foreach p,$^,-write $(p) $(subst build/,,$(p)))

# Targets
.PHONY: all clean

all: $(D64)

$(PRG): | $(OBJDIR)
$(BIN): | $(OBJDIR)

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(OBJDIR)

# Rules
$(PRG): $(BAS)
	$(MKPRG)

$(BIN): $(ASM)
	$(MKBIN)

$(D64): $(PRG) $(BIN) $(SPTBIN)
	$(MKD64)
