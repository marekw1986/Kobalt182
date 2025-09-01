        INCL "../common/definitions.asm"
        INCL "../common/utils.asm"

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
        MVI   A, 00H
        DB 0EDH, 039H, 032H     ; OUT0 32H
        MVI   A, 80H        
        OUT   WSG           ; I/O addr 0xD8

        ; Small delay to let bus decode settle (optional)
        NOP
        NOP

        ; Setup stack to top of mapped RAM
        LXI   H, 0FFDFH       ; Stack top
        SPHL
        
        ; ----------------------------
        ; Init PIO Port C
        ; ----------------------------
		; Set Port C to GPIO (parallel)
        MVI   A, 80H      ; SCR bit 7 = 1, other bits = 0
        OUT   SCR         ; Use definitions.asm to define SCR
        ; Configure only PC5 as output (others remain inputs)
        MVI   A, 0DFH          ; bit5 = 0 → PC5 output
        OUT   PCDIR            ; use label from definitions.asm

        ; Ensure PC5 high
        MVI   A, 20H
        OUT   PCDATA            ; use label from definitions.asm

; ----------------------------
; Blink loop on PC5
; ----------------------------
LOOP:
        MVI   A, 20H
        OUT   PCDATA
        
        ; To check if we can actually store values in RAM
        LXI   H,8200h
        MVI   A,55h
        MOV   M,A         ; write to RAM
        MVI   A,0
        MOV   A,M         ; read back
        CPI   55h
        JNZ   SKIP_D1

        MVI   B, 255
D1:     DCR   B
        JNZ   D1

SKIP_D1:

        MVI   A, 00H
        OUT   PCDATA
        
        ; To check if we can actually store values in RAM
        LXI   H,8200h
        MVI   A,55h
        MOV   M,A         ; write to RAM
        MVI   A,0
        MOV   A,M         ; read back
        CPI   55h
        JNZ   LOOP

        MVI   B, 255
D2:     DCR   B
        JNZ   D2

        JMP   LOOP

        END
