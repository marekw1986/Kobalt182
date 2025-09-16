# Adjust the run address to match the .org in the source code
all: bootloader_kobalt_z180.bin
	
bootloader_kobalt_z180.p: bootloader_kobalt_z180.asm
	asl -o bootloader_kobalt_z180.p -L -OLIST bootloader_kobalt_z180.lst bootloader_kobalt_z180.asm -cpu z180
	
bootloader_kobalt_z180.bin: bootloader_kobalt_z180.p
	p2bin -l '$$00' bootloader_kobalt_z180.p bootloader_kobalt_z180.bin

clean:
	$(RM) *.lst *.hex labels.asm *.bin *.p

distclean: clean
