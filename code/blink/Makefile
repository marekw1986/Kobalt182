# Adjust the run address to match the .org in the source code
all: blink_kobalt.bin blink_kobalt.hex

blink_kobalt.bin: blink_kobalt.hex
	objcopy --input-target=ihex --output-target=binary blink_kobalt.hex blink_kobalt.bin

blink_kobalt.hex: blink_kobalt.asm
	a85 blink_kobalt.asm -l blink_kobalt.lst -o blink_kobalt.hex 

clean:
	$(RM) *.lst *.hex *.bin

distclean: clean
