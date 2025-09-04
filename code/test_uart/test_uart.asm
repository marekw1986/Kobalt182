        INCL "../common/definitions.asm"

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
        MVI   A, 00H
        DB 0EDH, 039H, 032H     ; OUT0 32H
        MVI   A, 99H        
        OUT   WSG           ; I/O addr 0xD8

        ; Small delay to let bus decode settle (optional)
        NOP
        NOP

        ; Setup stack to top of mapped RAM
        LXI   H, 0FFDFH       ; Stack top
        SPHL

; --- Reset channel A ---
        mvi   a, 09h           ; WR9 (Reset and interrupt ESCC_A_CTRL)
        out   ESCC_A_CTRL
        mvi   a, 0C0h          ; Reset Channel A + Tx underrun
        out   ESCC_A_CTRL

; --- Async mode (8N1) ---
        mvi   a, 04h           ; Select WR4
        out   ESCC_A_CTRL
        mvi   a, 44h          ; 16× clock, 1 stop bit, 8 bits, async
        out   ESCC_A_CTRL

; --- Disable Rx (clear receiver parameters) ---
        mvi   a, 03h           ; Select WR3
        out   ESCC_A_CTRL
        mvi   a, 00h           ; Rx disabled
        ;mvi	  a, 01h		   ; Rx enabled
        out   ESCC_A_CTRL

; --- Enable Tx (and RTS) ---
        mvi   a, 05h           ; Select WR5
        out   ESCC_A_CTRL
        mvi   a, 0EAh          ; Tx enable, RTS, DTR 8-bit — 1110 1010b
        out   ESCC_A_CTRL

; --- Baud rate generator (BRG) setup ---
        ; Divisor ≈ 651 for 9600 baud @ 12.5 MHz clock
        mvi   a, 0Ch           ; Select WR12 (BRG low byte)
        out   ESCC_A_CTRL
        mvi   a, 08Bh          ; Low byte = 0x8B (139)
        out   ESCC_A_CTRL

        mvi   a, 0Dh           ; Select WR13 (BRG high byte)
        out   ESCC_A_CTRL
        mvi   a, 02h           ; High byte = 0x02 (2)
        out   ESCC_A_CTRL

        mvi   a, 0Eh           ; Select WR14 (BRG ESCC_A_CTRL)
        out   ESCC_A_CTRL
        mvi   a, 03h           ; Enable BRG and set clock source
        out   ESCC_A_CTRL

LOOP:
        mvi   A, 055h          ; ESCC_A_DATA to send
        CALL OUT_CHAR             
        
		MVI	  A, 255
		CALL  DELAY
		
        JMP   LOOP

		INCL "../common/utils.asm"

        END
