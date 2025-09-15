# Adjust the run address to match the .org in the source code
all: blink_count_kobalt.bin

blink_count_kobalt.p: blink_count_kobalt.asm
	asl -o blink_count_kobalt.p -L -OLIST blink_count_kobalt.lst blink_count_kobalt.asm -cpu 8080
	
blink_count_kobalt.bin: blink_count_kobalt.p
	p2bin -l '$$00' blink_count_kobalt.p blink_count_kobalt.bin
	
blink_count_kobalt_z180.p: blink_count_kobalt_z180.asm
	asl -o blink_count_kobalt_z180.p -L -OLIST blink_count_kobalt_z180.lst blink_count_kobalt_z180.asm -cpu z180
	
blink_count_kobalt_z180.bin: blink_count_kobalt_z180.p
	p2bin -l '$$00' blink_count_kobalt_z180.p blink_count_kobalt_z180.bin

clean:
	$(RM) *.lst *.hex *.bin *.p

distclean: clean
