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

	# load kernel

	# set up registers for int 0x13
	# get hard drive info
	mov $0, %bx
	mov %bx, %es
	mov %bx, %di
	mov $0x81, %dl # use 2nd hard drive
	mov $0x8, %ah # int 13 code to get drive parameters
	int $0x13

	# print stuff
	movb $0x0E, %ah # BIOS print code
	movb $97, %al # 'a'
	int $0x10 # send code to BIOS

	mov %ch, %bl # num sect/track
	mov %dh, %bh # num heads - 1
	add $1, %bh # num heads

	# calculate sector
	mov $0, %dx # reset high word for division
	div %bl # divide sector (ax) by num sectors/track (bl)
	add $1, %dl # sectors start at 1, not 0
	mov %dl, %cl # int 0x13 expects sector in cl
	mov %bx, %ax # restore logical sector to ax

	# print stuff
	movb $0x0E, %ah # BIOS print code
	movb $97, %al # 'a'
	int $0x10 # send code to BIOS

	# calculate head
	mov $0, %dx # reset high word for division
	div %bl # divide sector (ax) by num sectors/track (bl)
	mov $0, %dx # set remainder to 0
	div %bh # divide quotient (ax) by num heads (bh)
	mov %dl, %dh # int 0x13 expects head in dh
	mov %al, %ch # int 0x13 expects cylinder in ch

	# print stuff
	movb $0x0E, %ah # BIOS print code
	movb $97, %al # 'a'
	int $0x10 # send code to BIOS

	# load destination buffer into es:bx
	mov %ds, %si # 07C0
	add $512, %si # +512 (boot_loader)
	mov %ds, %bx # 07C0
	mov %bx, %es
	mov %si, %bx

	# print stuff
	movb $0x0E, %ah # BIOS print code
	movb $97, %al # 'a'
	int $0x10 # send code to BIOS

	# read
	mov $0x81, %dl # use 2nd drive
	mov $2, %ah # read parameter for int 0x13
	mov $2, %al # number of sectors (512 bytes each?) to read
	int $0x13 # read data

	# print stuff
	movb $0x0E, %ah # BIOS print code
	movb $98, %al # 'b'
	int $0x10 # send code to BIOS

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

