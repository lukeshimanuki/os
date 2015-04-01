.code16

.section .text
mbr:
	movw $0x07C0, %ax # set up 4kb stack
	addw $288, %ax
	movw %ax, %ss
	movw $4096, %sp

	movw $0x07C0, %ax
	movw %ax, %ds

	# print stuff
	movb $0x0E, %ah # BIOS print code
	movb $98, %al # increment char to print
	int $0x10 # send code to BIOS

	jmp . # continuous loop

.section .rodata
.word 0xAA55 # boot signature

