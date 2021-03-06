.code16

.extern boot_loader

.section .mbr, "x"
.global mbr
mbr:
	# set segment registers to 0
	movw $0x0000, %ax
	movw %ax, %fs
	movw %ax, %gs
	movw %ax, %ss
	movw %ax, %ds
	movw %ax, %es

	# set up stack below the load point
	movw $0x0000, %ax
	cli # disable interrupts
	movw %ax, %ss
	movw $0x7C00, %sp
	sti # enable interrupts

	# print a
	mov $97, %al
	mov $0x0E, %ah
	int $0x10

	# set data segment to where we're loaded
#	movw $0x07C0, %ax
#	movw %ax, %ds

	# load destination buffer into es:bx
	mov $0x7E00, %bx # 0x7C00 + 0x0200 (boot_loader)

	# set parameters
	mov $0, %ch # cylinder
	mov $0, %dh # head
	mov $2, %cl # sector

	# read
	mov $0x80, %dl # use 1st floppy (usb)
	mov $0x02, %ah # read parameter for int 0x13
	mov $0x01, %al # number of sectors (512 bytes each?) to read
	int $0x13 # read data

	# run boot loader
	mov $0x7E00, %ax
	mov %ax, %si
	jmp *%si

# prints byte in %al (0->aa, 255->pp)
print:
	push %ax
	mov $0x0E, %ah # print BIOS code
	and $0xF0, %al # take first 4 bits
	shr $4, %al # shift to the lower 4 bits
	add $97, %al # starts at 'a'
	int $0x10 # print
	pop %ax
	mov $0x0E, %ah # print BIOS code
	and $0x0F, %al # take last 4 bits
	add $97, %al # starts at 'a'
	int $0x10 # print
	mov $122, %al # separater
	int $0x10 # print
	ret

.section .boot_signature, ""
.word 0xAA55 # boot signature

