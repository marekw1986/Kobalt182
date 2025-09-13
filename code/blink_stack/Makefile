# Adjust the run address to match the .org in the source code
all: blink_kobalt.bin blink_kobalt.hex

blink_kobalt.bin: blink_kobalt.hex
	objcopy --input-target=ihex --output-target=binary blink_kobalt.hex blink_kobalt.bin

blink_kobalt.hex: blink_kobalt.asm
	a85 blink_kobalt.asm -l blink_kobalt.lst -o blink_kobalt.hex 
	
blink_kobalt_z180.p: blink_kobalt_z180.asm
	asl -o blink_kobalt_z180.p -L -OLIST blink_kobalt_z180.lst blink_kobalt_z180.asm -cpu z180
	
blink_kobalt_z180.bin: blink_kobalt_z180.p
	p2bin -l '$$00' blink_kobalt_z180.p blink_kobalt_z180.bin

clean:
	$(RM) *.lst *.hex *.bin *.p

distclean: clean
