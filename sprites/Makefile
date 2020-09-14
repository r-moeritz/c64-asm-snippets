# Paths
OBJDIR := build
SRC := sprites.s
PRG := $(OBJDIR)/sprites.prg
D64 := $(OBJDIR)/sprites.d64

# Commands
MKPRG = tmpx -o $(PRG) -i $(SRC)
RM := rm -rf
MKDIR := mkdir -p
MKD64 = mkd64 -o $(D64) -m cbmdos -d 'SPRITES' -m separators \
-f $(PRG) -n BALLOON -w

# Targets
.PHONY: all clean

all: $(D64)

$(PRG): | $(OBJDIR)

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(OBJDIR)

# Rules
$(PRG): $(SRC)
	$(MKPRG)

$(D64): $(PRG) 
	$(MKD64)
