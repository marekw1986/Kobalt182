        INCL "../common/definitions.asm"

        ORG   0000H
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
        XOR A
        DB 0EDH, 039H, 032H     ; OUT0 32H
        MVI   A, 88H        
        OUT   WSG           ; I/O addr 0xD8

        ; Small delay to let bus decode settle (optional)
        NOP
        NOP
        
        ; ----------------------------
        ; Init PIO Port A
        ; ----------------------------
		; Set Port C to GPIO (parallel)
;        MVI   A, 80H      ; SCR bit 7 = 1, other bits = 0
;        OUT   SCR         ; Use definitions.asm to define SCR
        ; Configure all lines as outputs
        XOR A
        OUT   PADIR            ; use label from definitions.asm

        ; Ensure all PA lines low
        XOR A
        OUT   PADATA            ; use label from definitions.asm
        
        ; Setup stack to top of mapped RAM
        LXI   H, 8200H       ; Stack top
        SPHL
        
        NOP
        NOP
        NOP

; ----------------------------
; Blink loop on PA
; ----------------------------
LOOP:
        MVI   A, 0FFH
        OUT   PADATA
        
        MVI   A, 255
        CALL DELAY

        XOR A
        OUT   PADATA
        
        MVI   A, 255
        CALL DELAY

        JMP   LOOP
        
        INCL "../common/utils.asm"

        END
