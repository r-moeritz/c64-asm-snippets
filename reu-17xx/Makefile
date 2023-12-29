# Paths
OBJDIR := build
SRC := routines.s
PRG := $(OBJDIR)/routines.prg
D64 := $(OBJDIR)/routines.d64
ASM := java -cp "$(HOME)/Programs/KickAssembler/*" kickass.KickAssembler

# Commands
MKPRG = $(ASM) -odir $(OBJDIR) $(SRC) -bytedump
RM := rm -rf
MKDIR := mkdir -p
MKD64 = c1541 -format routines,routines d64 $@ $(foreach p,$(PRG),-write $(p) $(subst .prg,,$(subst build/,,$(p))))

# Targets
.PHONY: all clean

all: $(D64)

$(PRG): | $(OBJDIR)

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(OBJDIR) *.o

# Rules
$(PRG): $(SRC)
	$(MKPRG)

$(D64): $(PRG) 
	$(MKD64)
