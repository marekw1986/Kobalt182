# Adjust the run address to match the .org in the source code
all: test_uart_kobalt_z180.bin
	
test_uart_kobalt_z180.p: test_uart_kobalt_z180.asm
	asl -o test_uart_kobalt_z180.p -L -OLIST test_uart_kobalt_z180.lst test_uart_kobalt_z180.asm -cpu z180
	
test_uart_kobalt_z180.bin: test_uart_kobalt_z180.p
	p2bin -l '$$00' test_uart_kobalt_z180.p test_uart_kobalt_z180.bin

clean:
	$(RM) *.lst *.hex *.bin *.p

distclean: clean
