        include "../common/definitions.asm"

        ORG   0000H
START:  
        DI

        ; ----------------------------
        ; MMU / RAM mapping
        ; ----------------------------
        ; --- Program ROM window (0x0000–0x7FFF) ---
        LD   A, 07H        ; upper block = 0x07 (0x7000–0x7FFF)
        OUT   (ROMBR), A         ; I/O E8h

        ; --- Program RAM window (0x8000–0xFFFF) ---
        LD   A, 08H        ; lower block = 0x08 (0x8000)
        OUT   (RAMLBR), A        ; I/O E7h
        LD   A, 0FH        ; upper block = 0x0F (0xF000–0xFFFF)
        OUT   (RAMUBR), A        ; I/O E6h

        ; Configure Wait State Generator
        LD   A, 00H
        OUT0 (DCNTL), A     ; DB 0EDH, 039H, 032H
        LD   A, 99H        
        OUT   (WSG), A           ; I/O addr 0xD8

        ; Small delay to let bus decode settle (optional)
        NOP
        NOP
        
        ; ----------------------------
        ; Init IO Ports
        ; ----------------------------
		; Set Port B to GPIO (parallel)
        LD   A, 60H      ; SCR bit 7 = 0, bit 6 = 1, bit 5 = 1, other bits = 0
        OUT   (SCR), A         ; Use definitions.asm to define SCR
        ; Configure all lines as outputs
        XOR A
        OUT   (PADIR), A            ; use label from definitions.asm
        ; Ensure all PA lines low
        XOR A
        OUT   (PADATA), A            ; use label from definitions.asm
        
        LD   A, 1FH                ; PB0..Pb4 inputs, PB5..PB7 outputs
        OUT   (PBDIR), A
        XOR A
        OUT   (PBDATA), A
        
        ; Setup stack to top of mapped RAM
        LD   HL, 8200H       ; Stack top
        LD   SP, HL
        
        NOP
        NOP
        NOP

; ----------------------------
; Blink loop on PA
; ----------------------------
LOOP:
        LD   A, 055H
        OUT   (PADATA), A
        
        LD   C, 255
        CALL DELAY

        LD   A, 0AAH
        OUT   (PADATA), A
        
        LD   C, 255
        CALL DELAY

        JP   LOOP
        
        include "../common/utils_z180.asm"

        END
