all:
	ca65 -g --cpu 6502X -U --feature force_range -o DecrZero.o DecrZero.s
	ld65 -C Linkfile.decrunch -Ln symbols DecrZero.o -o DecrZero.prg
	gcc -O3 converttoheader.c -o converttoheader.exe
	./converttoheader.exe DecrZero.prg symbols DecrZero.h
	gcc -O3 file.c cruncher.c bb.c -o b2.exe

clean:
	rm *.exe
	rm symbols
	rm *.o
	rm *.prg
	rm DecrZero.h
	