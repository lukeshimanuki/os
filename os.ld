/* object files are located in the build directory */
SEARCH_DIR(build)

/* load the input files */
INPUT(mbr.o)

/* output as flat binary */
OUTPUT(bin/os.bin)
OUTPUT_FORMAT(binary)

SECTIONS
{
	.text 0 :
	{
		mbr.o (.text)
	}
	.rodata 510 :
	{
		mbr.o (.rodata)
	}
}

