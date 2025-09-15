        include "../common/definitions.asm"

        ORG   00000H
START:
        DI

        ; ----------------------------
        ; MMU / RAM mapping
        ; ----------------------------
        ; --- Program ROM window (0x0000–0x7FFF) ---
        MVI   A, 07H        ; upper block = 0x07 (0x7000–0x7FFF)
        OUT   ROMBR         ; I/O E8h

        ; --- Program RAM window (0x8000–0xFFFF) ---
        MVI   A, 08H        ; lower block = 0x08 (0x8000)
        OUT   RAMLBR        ; I/O E7h
        MVI   A, 0FH        ; upper block = 0x0F (0xF000–0xFFFF)
        OUT   RAMUBR        ; I/O E6h

        ; Configure Wait State Generator
        XRA A
        DB 0EDH, 039H, 032H     ; OUT0 32H
        MVI   A, 88H        
        OUT   WSG           ; I/O addr 0xD8

        ; Small delay to let bus decode settle (optional)
        NOP
        NOP
        
        MVI	  A, 04H		; Normal (level based detection for INT1 and INT2, MREQ, RTSA/PC2, IOCS, no low noise, no wait delay on HALT,
        OUT	  IEPMR
        
        ; ----------------------------
        ; Init PIO Port A
        ; ----------------------------
		; Set Port B to GPIO (parallel)
        MVI   A, 60H      ; SCR bit 7 = 0, bit 6 = 1, bit 5 = 1, other bits = 0
        OUT   SCR         ; Use definitions.asm to define SCR
        ; Configure all lines as outputs
        XRA A
        OUT   PADIR            ; use label from definitions.asm
        ; Ensure all PA lines low
        XRA A
        OUT   PADATA            ; use label from definitions.asm
        
        MVI   A, 1FH                ; PB0..Pb4 inputs, PB5..PB7 outputs
        OUT   PBDIR
        XRA A
        OUT   PBDATA

        ; Setup stack to top of mapped RAM
        LXI   H, 0FFDFH       ; Stack top
        SPHL
        
        NOP
        NOP
        NOP

; --- Reset channel A ---
        MVI   A, 09h           ; WR9 (Reset and interrupt ESCC_A_CTRL)
        OUT   ESCC_A_CTRL
        MVI   A, 0C0h          ; Reset Channel A + Tx underrun
        OUT   ESCC_A_CTRL

; --- Async mode (8N1) ---
        MVI   A, 04h           ; Select WR4
        OUT   ESCC_A_CTRL
        MVI   A, 44h          ; 16× clock, 1 stop bit, 8 bits, async
        OUT   ESCC_A_CTRL

; --- Disable Rx (clear receiver parameters) ---
        MVI   A, 03h           ; Select WR3
        OUT   ESCC_A_CTRL
        XRA A           ; Rx disabled
        ;MVI	  A, 01h		   ; Rx enabled
        OUT   ESCC_A_CTRL

; --- Enable Tx (and RTS) ---
        MVI   A, 05h           ; Select WR5
        OUT   ESCC_A_CTRL
        MVI   A, 0EAh          ; Tx enable, RTS, DTR 8-bit — 1110 1010b
        OUT   ESCC_A_CTRL

; --- Baud rate generator (BRG) setup ---
        ; Divisor ≈ 651 for 9600 baud @ 12.5 MHz clock
        MVI   A, 0Ch           ; Select WR12 (BRG low byte)
        OUT   ESCC_A_CTRL
        MVI   A, 08Bh          ; Low byte = 0x8B (139)
        OUT   ESCC_A_CTRL

        MVI   A, 0Dh           ; Select WR13 (BRG high byte)
        OUT   ESCC_A_CTRL
        MVI   A, 02h           ; High byte = 0x02 (2)
        OUT   ESCC_A_CTRL

        MVI   A, 0Eh           ; Select WR14 (BRG ESCC_A_CTRL)
        OUT   ESCC_A_CTRL
        MVI   A, 03h           ; Enable BRG and set clock source
        OUT   ESCC_A_CTRL

LOOP:
        MVI   A, 055h          ; ESCC_A_DATA to send
        CALL OUT_CHAR             
        
        MVI   A, 0FFH
        OUT   PADATA
        
		MVI	  C, 255
		CALL  DELAY
        
        XRA A
        OUT   PADATA
        
        MVI   C, 255
        CALL DELAY
		
        JMP   LOOP

		include "../common/utils.asm"

        END
