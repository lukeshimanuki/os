.code16

.text
.global start
.type start, @function
start:
	movw $0x07C0, %ax # set up 4kb stack
	addw $288, %ax # 
	movw %ax, %ss
	movw $4096, %sp

	movw $0x07C0, %ax
	movw %ax, %ds

	movw $.textstring, %si
	call print

	jmp . # if you get here, just continuously jump to here (infinite loop)

.text
.global print
.type print, @function
print:
	movb $0x0E, %ah # print char BIOS code
.LOOP_BEG0:
	lodsb # load char from %si into %al
	cmpb $0, %al
	je .LOOP_END0 # end at null
	int $0x10 # send code to BIOS
	jmp .LOOP_BEG0 # repeat
.LOOP_END0:
	ret

.section .rodata
.textstring:
	.string "message"

.skip 466 # jump to end
.word 0xAA55 # boot signature

