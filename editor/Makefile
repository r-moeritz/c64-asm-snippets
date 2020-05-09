# Paths
OBJDIR := build
SRC := ed.s
PRG := $(OBJDIR)/ed.prg
D64 := $(OBJDIR)/ed.d64

# Commands
MKPRG = cl65 -o $(PRG) --start-addr 52000 -t c64 -C c64-asm.cfg $(SRC)
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
