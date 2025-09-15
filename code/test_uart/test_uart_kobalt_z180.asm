        include "../common/definitions.asm"

        ORG   00000H
START:
        DI

        ; ----------------------------
        ; MMU / RAM mapping
        ; ----------------------------
        ; --- Program ROM window (0x0000–0x7FFF) ---
        LD A, 07H        ; upper block = 0x07 (0x7000–0x7FFF)
        OUT (ROMBR), A         ; I/O E8h

        ; --- Program RAM window (0x8000–0xFFFF) ---
        LD A, 08H        ; lower block = 0x08 (0x8000)
        OUT (RAMLBR), A        ; I/O E7h
        LD A, 0FH        ; upper block = 0x0F (0xF000–0xFFFF)
        OUT (RAMUBR), A        ; I/O E6h

        ; Configure Wait State Generator
        XOR A
        OUT0 (DCNTL), A ; DB 0EDH, 039H, 032H     ; OUT0 32H
        LD A, 88H        
        OUT (WSG), A           ; I/O addr 0xD8

        ; Small delay to let bus decode settle (optional)
        NOP
        NOP
        
        LD	A, 04H		; Normal (level based detection for INT1 and INT2, MREQ, RTSA/PC2, IOCS, no low noise, no wait delay on HALT,
        OUT	(IEPMR), A
        
        ; ----------------------------
        ; Init PIO Port A
        ; ----------------------------
		; Set Port B to GPIO (parallel)
        LD A, 60H      ; SCR bit 7 = 0, bit 6 = 1, bit 5 = 1, other bits = 0
        OUT (SCR), A         ; Use definitions.asm to define SCR
        ; Configure all lines as outputs
        XOR A
        OUT (PADIR), A            ; use label from definitions.asm
        ; Ensure all PA lines low
        XOR A
        OUT (PADATA), A            ; use label from definitions.asm
        
        LD A, 1FH                ; PB0..Pb4 inputs, PB5..PB7 outputs
        OUT (PBDIR), A
        XOR A
        OUT (PBDATA), A

        ; Setup stack to top of mapped RAM
        LD SP, 0FFDFH       ; Stack top
        
        NOP
        NOP
        NOP

; --- Reset channel A ---
        LD A, 09h           ; WR9 (Reset and interrupt ESCC_A_CTRL)
        OUT (ESCC_A_CTRL), A
        LD A, 0C0h          ; Reset Channel A + Tx underrun
        OUT (ESCC_A_CTRL), A

; --- Async mode (8N1) ---
        LD A, 04h           ; Select WR4
        OUT (ESCC_A_CTRL), A
        LD A, 44h          ; 16× clock, 1 stop bit, 8 bits, async
        OUT (ESCC_A_CTRL), A

; --- Disable Rx (clear receiver parameters) ---
        LD A, 03h           ; Select WR3
        OUT (ESCC_A_CTRL), A
        XOR A           ; Rx disabled
        ;LD	A, 01h		   ; Rx enabled
        OUT (ESCC_A_CTRL), A

; --- Enable Tx (and RTS) ---
        LD A, 05h           ; Select WR5
        OUT (ESCC_A_CTRL), A
        LD A, 0EAh          ; Tx enable, RTS, DTR 8-bit — 1110 1010b
        OUT (ESCC_A_CTRL), A

; --- Baud rate generator (BRG) setup ---
        ; Divisor ≈ 651 for 9600 baud @ 12.5 MHz clock
        LD A, 0Ch           ; Select WR12 (BRG low byte)
        OUT (ESCC_A_CTRL), A
        LD A, 08Bh          ; Low byte = 0x8B (139)
        OUT (ESCC_A_CTRL), A

        LD A, 0Dh           ; Select WR13 (BRG high byte)
        OUT (ESCC_A_CTRL), A
        LD A, 02h           ; High byte = 0x02 (2)
        OUT (ESCC_A_CTRL), A

        LD A, 0Eh           ; Select WR14 (BRG ESCC_A_CTRL)
        OUT (ESCC_A_CTRL), A
        LD A, 03h           ; Enable BRG and set clock source
        OUT (ESCC_A_CTRL), A

LOOP:
        LD A, 055h          ; ESCC_A_DATA to send
        CALL OUT_CHAR             
        
        LD A, 0FFH
        OUT (PADATA), A
        
		LD	C, 255
		CALL DELAY
        
        XOR A
        OUT (PADATA), A
        
        LD   C, 255
        CALL DELAY
		
        JP   LOOP

		include "../common/utils_z180.asm"

        END
