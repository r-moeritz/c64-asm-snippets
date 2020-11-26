# Paths
OBJDIR := build
SRC := centronics.s
PRG := $(OBJDIR)/centronics.prg
D64 := $(OBJDIR)/centronics.d64

# Commands
MKPRG = tmpx -o $(PRG) -i $(SRC)
RM := rm -rf
MKDIR := mkdir -p
MKD64 = mkd64 -o $(D64) -m cbmdos -d 'CENTRONICS' -m separators \
-f $(PRG) -n DRIVER -w
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
