rm -f os.bin os.img

as os.s -o os.o
ld -T os.ld --oformat binary -o os.bin os.o
dd status=noxfer conv=notrunc if=os.bin of=os.img

