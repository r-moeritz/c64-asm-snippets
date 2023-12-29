# Paths
OBJDIR := build
SRC := fileio.s
PRG := $(OBJDIR)/fileio.prg
D64 := $(OBJDIR)/fileio.d64
ASM := java -cp "$(HOME)/Programs/KickAssembler/*" kickass.KickAssembler

# Commands
MKPRG = $(ASM) -odir $(OBJDIR) -bytedump $(SRC)
RM := rm -rf
MKDIR := mkdir -p
MKD64 = c1541 -format ed,ed d64 $@ $(foreach p,$(PRG),-write $(p) $(subst .prg,,$(subst build/,,$(p))))

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
