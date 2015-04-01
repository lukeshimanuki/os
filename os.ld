/* object files are located in the build directory */
SEARCH_DIR(build)

/* load the input files */
INPUT(mbr.o)

/* output as flat binary */
OUTPUT(bin/os.bin)
OUTPUT_FORMAT(binary)

SECTIONS
{
	/* the first 512 bytes, loaded on boot */
	.mbr 0 :
	{
		addr_mbr = ABSOLUTE(.);
		/* code to run at boot */
		mbr.o (.mbr)
		. = addr_mbr + 510;
		/* the last 2 bytes, BIOS looks for this code */
		mbr.o (.boot_signature)
	} = 0 /* fill gaps with 0s */
}

