# Paths
OBJDIR := build
SRC := multi.s
BIN := $(OBJDIR)/multi.bin
PRG := $(OBJDIR)/multi.prg
D64 := $(OBJDIR)/multi.d64
ASM := java -cp "$(HOME)/Programs/KickAssembler/*" kickass.KickAssembler

# Commands
MKBIN = $(ASM) -odir $(OBJDIR) -o $(BIN) $(SRC)
MKPRG = pucrunch -x4096 -m6 $(BIN) $(PRG)
RM := rm -rf
MKDIR := mkdir -p
MKD64 = c1541 -format multi,multi d64 $@ $(foreach p,$(PRG),-write $(p) $(subst .prg,,$(subst build/,,$(p))))

# Targets
.PHONY: all clean

all: $(D64)

$(BIN): | $(OBJDIR)

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

clean:
	$(RM) $(OBJDIR) *.o

# Rules
$(BIN): $(SRC)
	$(MKBIN)

$(PRG): $(BIN)
	$(MKPRG)

$(D64): $(PRG) 
	$(MKD64)
