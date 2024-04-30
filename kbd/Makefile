# Paths
OBJDIR := build
SRC := kbd.asm
PRG := $(OBJDIR)/kbd.prg
LAB := $(OBJDIR)/kbd.lab
LST := $(OBJDIR)/kbd.lst
D64 := $(OBJDIR)/kbd.d64
ASM := 64tass

# Commands
MKPRG = $(ASM) -a -m -L $(LST) -l $(LAB) -o $(PRG) $(SRC)
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
