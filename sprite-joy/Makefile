# Paths
OBJDIR := build
SRC := sprites.s
PRG := $(OBJDIR)/sprites.prg
D64 := $(OBJDIR)/sprites.d64

# Commands
MKPRG = java -cp "$(HOME)/Programs/KickAssembler/*" kickass.KickAssembler -odir $(OBJDIR) -bytedump $(SRC)
RM := rm -rf
MKDIR := mkdir -p
MKD64 = c1541 -format routines,routines d64 $@ $(foreach p,$(PRG),-write $(p) $(subst .prg,,$(subst build/,,$(p))))
X64 := x64sc

# Targets
.PHONY: all clean run

all: $(D64)

$(PRG): | $(OBJDIR)

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(OBJDIR)

run: $(PRG)
	$(X64) $(PRG)

# Rules
$(PRG): $(SRC)
	$(MKPRG)

$(D64): $(PRG) 
	$(MKD64)
