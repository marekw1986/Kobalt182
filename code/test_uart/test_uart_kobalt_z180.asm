        include "../common/definitions.asm"

        ORG   00000H
START:
        DI

        ; ----------------------------
        ; MMU / RAM mapping
        ; ----------------------------
        ; --- Program ROM window (0x0000–0x7FFF) ---
        LD A, 07H        ; upper block = 0x07 (0x7000–0x7FFF)
        OUT0 (ROMBR), A         ; I/O E8h

        ; --- Program RAM window (0x8000–0xFFFF) ---
        LD A, 08H        ; lower block = 0x08 (0x8000)
        OUT0 (RAMLBR), A        ; I/O E7h
        LD A, 0FH        ; upper block = 0x0F (0xF000–0xFFFF)
        OUT0 (RAMUBR), A        ; I/O E6h

        ; Configure Wait State Generator
        XOR A
        OUT0 (DCNTL), A ; DB 0EDH, 039H, 032H     ; OUT0 32H
        LD A, 88H        
        OUT0 (WSG), A           ; I/O addr 0xD8

        ; Small delay to let bus decode settle (optional)
        NOP
        NOP
        
        LD	A, 04H		; Normal (level based detection for INT1 and INT2, MREQ, RTSA/PC2, IOCS, no low noise, no wait delay on HALT,
        OUT0 (IEPMR), A
        
        ; ----------------------------
        ; Init PIO Port A
        ; ----------------------------
		; Set Port B to GPIO (parallel)
        LD A, 60H      ; SCR bit 7 = 0, bit 6 = 1, bit 5 = 1, other bits = 0
        OUT0 (SCR), A         ; Use definitions.asm to define SCR
        ; Configure all lines as outputs
        XOR A
        OUT0 (PADIR), A            ; use label from definitions.asm
        ; Ensure all PA lines low
        XOR A
        OUT0 (PADATA), A            ; use label from definitions.asm
        
        LD A, 1FH                ; PB0..Pb4 inputs, PB5..PB7 outputs
        OUT0 (PBDIR), A
        XOR A
        OUT0 (PBDATA), A

        ; Setup stack to top of mapped RAM
        LD SP, 0FFDFH       ; Stack top
        
        NOP
        NOP
        NOP

; --- Reset channel A ---
;        LD A, 09h           ; WR9 (Reset and interrupt ESCC_A_CTRL)
;        OUT0 (ESCC_A_CTRL), A
;        LD A, 0C0h          ; Reset Channel A + Tx underrun
;        OUT0 (ESCC_A_CTRL), A

; --- Async mode (8N1) ---
        LD A, 04h           ; Select WR4
        OUT0 (ESCC_A_CTRL), A
        LD A, 44h          ; 16× clock, 1 stop bit, 8 bits, async
        OUT0 (ESCC_A_CTRL), A
        
; --- Parity is a special condition ---
;        LD A, 01H
;        OUT0 (ESCC_A_CTRL), A
;        LD A, 04H
;        OUT0 (ESCC_A_CTRL), A

; --- RX 8 bits/char ---
        LD A, 03H           ; Select WR3
        OUT0 (ESCC_A_CTRL), A
        LD	A, 0C0H
        OUT0 (ESCC_A_CTRL), A

; --- TX 8 bits/char ---
        LD A, 05H           ; Select WR5
        OUT0 (ESCC_A_CTRL), A
        LD A, 60H
        OUT0 (ESCC_A_CTRL), A
        
; --- Status affects int. vector ---
;        LD A, 09H           ; Select WR5
;        OUT0 (ESCC_A_CTRL), A
;        LD A, 01H
;        OUT0 (ESCC_A_CTRL), A        

; --- RX & TX <- BRG, RTxC <- BRG ---        
        LD A, 0BH           ; Select WR11
        OUT0 (ESCC_A_CTRL), A
        LD A, 56H
        OUT0 (ESCC_A_CTRL), A

; --- Baud rate generator (BRG) setup ---
        ; Divisor ≈ 651 for 9600 baud @ 12.5 MHz clock
        LD A, 0CH           ; Select WR12 (BRG low byte)
        OUT0 (ESCC_A_CTRL), A
        LD A, 27H          ; Low byte = 0x8B (139)
        OUT0 (ESCC_A_CTRL), A

        LD A, 0DH           ; Select WR13 (BRG high byte)
        OUT0 (ESCC_A_CTRL), A
        XOR A               ; High byte =0 (2)
        OUT0 (ESCC_A_CTRL), A
        
; --- BRG source (internal) DPLL off ---  
        LD A, 0EH           ; Select WR14 (BRG ESCC_A_CTRL)
        OUT0 (ESCC_A_CTRL), A
        LD A, 62H
        OUT0 (ESCC_A_CTRL), A
        
; --- BRG enabled ---  
        LD A, 0EH           ; Select WR14 (BRG ESCC_A_CTRL)
        OUT0 (ESCC_A_CTRL), A
        LD A, 03H
        OUT0 (ESCC_A_CTRL), A
        
; --- Enable ints. here, if reqd. --- 
;        LD A, 01H           ; Select WR1 (BRG ESCC_A_CTRL)
;        OUT0 (ESCC_A_CTRL), A
;        LD A, 04H
;        OUT0 (ESCC_A_CTRL), A

; --- No "advanced" features ---  
        LD A, 0FH           ; Select WR15 (BRG ESCC_A_CTRL)
        OUT0 (ESCC_A_CTRL), A
        XOR A               ; A = 0
        OUT0 (ESCC_A_CTRL), A
        
; --- No "advanced" features ---  
        XOR A           ; Select WR0 (BRG ESCC_A_CTRL)
        OUT0 (ESCC_A_CTRL), A
        LD A, 10H
        OUT0 (ESCC_A_CTRL), A
        
; --- Repeat, to be sure of it ---  
        XOR A           ; Select WR0 (BRG ESCC_A_CTRL)
        OUT0 (ESCC_A_CTRL), A
        LD A, 10H
        OUT0 (ESCC_A_CTRL), A
        
; --- RX enabled ---  
        LD A, 03H           ; Select WR3 (BRG ESCC_A_CTRL)
        OUT0 (ESCC_A_CTRL), A
        LD A, 0C1H
        OUT0 (ESCC_A_CTRL), A
        
; --- TX enabled, RTS active ---
        LD A, 05H           ; Select WR5
        OUT0 (ESCC_A_CTRL), A
        LD A, 6AH
        OUT0 (ESCC_A_CTRL), A

LOOP:
        LD A, 055h          ; ESCC_A_DATA to send
        CALL OUT_CHAR             
        
        LD A, 0FFH
        OUT0 (PADATA), A
        
		LD	C, 255
		CALL DELAY
        
        XOR A
        OUT0 (PADATA), A
        
        LD   C, 255
        CALL DELAY
		
        JP   LOOP

		include "../common/utils_z180.asm"

        END
