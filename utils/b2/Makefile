all:
	ca65 -g --cpu 6502X -U --feature force_range -o DecrZero.o DecrZero.s
	ld65 -C Linkfile.DecrZero -Ln DecrZero.symbols DecrZero.o -o DecrZero.prg

	ca65 -g --cpu 6502X -U --feature force_range -o DecrZeroInit.o DecrZeroInit.s
	ld65 -C Linkfile.DecrZeroInit -Ln DecrZeroInit.symbols DecrZeroInit.o -o DecrZeroInit.prg

	gcc -O3 converttoheader.c -o converttoheader.exe
	./converttoheader.exe DecrZero.prg DecrZeroInit.prg DecrZero.symbols DecrZeroInit.symbols DecrZero.h
	gcc -O3 file.c cruncher.c bb.c -o b2.exe

clean:
	rm *.exe
	rm *.symbols
	rm *.o
	rm *.prg
	rm DecrZero.h
