.code16

.extern boot_loader

.section .mbr, "x"
.global mbr
mbr:
	# set up 4kb stack
	movw $0x07C0, %ax
	addw $288, %ax
	movw %ax, %ss
	movw $4096, %sp

	movw $0x07C0, %ax
	movw %ax, %ds

	# print
	mov $0x0E, %ah
	mov $97, %al # 'a'
	int $0x10

	# load kernel

	# set up registers for int 0x13
	# get hard drive info
	mov $0, %bx
	mov %bx, %es
	mov %bx, %di
	mov $0x00, %dl # use 1st floppy (usb)
	mov $0x08, %ah # int 13 code to get drive parameters
	int $0x13

	mov %ch, %cl
	mov $0, %ch
	mov %cx, %bx # sects/track

	# save num heads
	add $1, %dh
	mov %dh, %dl
	mov $0, %dh
	push %dx

	# calculate sector
	mov $1, %ax # start at 2nd sector
	mov $0, %dx # reset high word for division
	div %bx # divide sector (ax) by num sectors/track (bx)
	add $1, %dl # sectors start at 1, not 0
	mov %dl, %cl # int 0x13 expects sector in cl

	# calculate head
	mov $1, %ax # start at 2nd sector
	mov $0, %dx # reset high word for division
	div %bx # divide sector (ax) by num sectors/track (bx)
	mov $0, %dx # set remainder to 0
	pop %bx # num heads
	div %bx # divide quotient (ax) by num heads (bx)
	mov %dl, %dh # int 0x13 expects head in dh
	mov %al, %ch # int 0x13 expects cylinder in ch

	# load destination buffer into es:bx
	mov $0x00, %bx
	mov %bx, %es # 0x00
	mov $0x09C0, %bx # 0x07C0 + 512 (boot_loader)

	# print stuff
	mov %ch, %al # cylinder
	call print
	mov %dh, %al # head
	call print
	mov %cl, %al # sector
	call print

	# read
	mov $0x00, %dl # use 1st floppy (usb)
	mov $2, %ah # read parameter for int 0x13
	mov $2, %al # number of sectors (512 bytes each?) to read
	int $0x13 # read data

	# test print func
	mov $0x12, %al # "bc"
	call print

	# print loaded memory
	mov $0x09C0, %bx # 0x07C0 + 512 (boot_loader)
	mov (%bx), %al
	call print

	# run boot loader
	mov %ds, %si
	add $512, %si
	call %si

.end:
	cli
	hlt
	jmp .end

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

