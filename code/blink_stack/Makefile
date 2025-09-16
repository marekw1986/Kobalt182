# Adjust the run address to match the .org in the source code
all: blink_kobalt_z180.bin
	
blink_kobalt_z180.p: blink_kobalt_z180.asm
	asl -o blink_kobalt_z180.p -L -OLIST blink_kobalt_z180.lst blink_kobalt_z180.asm -cpu z180
	
blink_kobalt_z180.bin: blink_kobalt_z180.p
	p2bin -l '$$00' blink_kobalt_z180.p blink_kobalt_z180.bin

clean:
	$(RM) *.lst *.hex *.bin *.p

distclean: clean
