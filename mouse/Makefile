# Paths
OBJDIR := build
ASM := mouse64.s
BAS := demo64.bas
SPT := sprites.0e00
BIN := $(OBJDIR)/mouse64.bin
PRG := $(OBJDIR)/demo64
SPTBIN := $(OBJDIR)/$(SPT)
D64 := $(OBJDIR)/1351-mouse-demo.d64

# Commands
MKPRG = petcat -w2 -o $@ -- $<
MKBIN = java -cp "$(HOME)/Programs/KickAssembler/*" kickass.KickAssembler -odir $(OBJDIR) -o $@ $<
RM := rm -rf
CP = cp $< $@
MKDIR := mkdir -p
MKD64 = c1541 -format 1351-mouse-demo,md d64 $@ -attach $@ $(foreach p,$^,-write $(p) $(subst build/,,$(p)))

# Targets
.PHONY: all clean

all: $(D64)

$(PRG): | $(OBJDIR)
$(BIN): | $(OBJDIR)
$(SPTBIN): | $(OBJDIR)

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(OBJDIR)

# Rules
$(PRG): $(BAS)
	$(MKPRG)

$(BIN): $(ASM)
	$(MKBIN)

$(SPTBIN): $(SPT)
	$(CP)

$(D64): $(PRG) $(BIN) $(SPTBIN)
	$(MKD64)

