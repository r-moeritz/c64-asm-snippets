all: multi.prg

multi.prg: multi.asm
	dasm multi.asm -omulti.bin -v3 -p3
	pucrunch -x4096 -m6 multi.bin multi.prg

clean:
	rm multi.bin multi.prg

.PHONY: all clean
