.section .boot_loader, "wx"
.global boot_loader
boot_loader:
	# print stuff
	movb $0x0E, %ah # BIOS print code
	movb $98, %al # 'b'
	int $0x10 # send code to BIOS
.end:
	cli
	hlt
	jmp .end

