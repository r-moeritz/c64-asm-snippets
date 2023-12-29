# Paths
OBJDIR := build
SRC := $(wildcard *.s)
PRG := $(SRC:%.s=$(OBJDIR)/%.prg)
D64 := $(OBJDIR)/georam.d64

# Commands
MKPRG = java -cp "$(HOME)/Programs/KickAssembler/*" kickass.KickAssembler -odir $(OBJDIR) -bytedump
RM := rm -rf
MKDIR := mkdir -p
MKD64 := c1541 -format georam,gr d64

# Rules
$(OBJDIR)/%.prg: %.s
	$(MKPRG) $<

# Targets
.PHONY: all d64 clean

all: d64

d64: $(PRG)
	$(MKD64) $(D64) -attach $(D64) $(foreach p,$(PRG),-write $(p) $(subst .prg,,$(subst build/,,$(p))))

$(SRC): | $(OBJDIR)

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(OBJDIR)
