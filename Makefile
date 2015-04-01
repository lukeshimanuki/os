all: os.img

os.img: bin/os.bin
	rm -f os.img
	dd status=noxfer conv=notrunc if=bin/os.bin of=os.img

bin/os.bin: os.ld build/mbr.o
	ld -T os.ld

build/mbr.o: src/mbr.s
	as src/mbr.s -o build/mbr.o

dump: os.img
	objdump -m i386:x64-32 -b binary -D os.img

clean:
	rm -f os.img
	rm -f bin/os.bin
	rm -f build/mbr.o

