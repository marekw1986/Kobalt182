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
        XRA A
        DB 0EDH, 039H, 032H     ; OUT0 32H
        MVI   A, 99H        
        OUT   WSG           ; I/O addr 0xD8

        ; Small delay to let bus decode settle (optional)
        NOP
        NOP

        ; Setup stack to top of mapped RAM
        LXI   H, 0FFDFH       ; Stack top
        SPHL
        
        ; ----------------------------
        ; Init PIO Port A
        ; ----------------------------
		; Set Port B to GPIO (parallel)
        MVI   A, 60H      ; SCR bit 7 = 0, bit 6 = 1, bit 5 = 1, other bits = 0
        OUT   SCR         ; Use definitions.asm to define SCR
        ; Configure only all lines as outputs
        XRA A
        OUT   PADIR            ; use label from definitions.asm
        ; Ensure all PA lines high
        MVI   A, 0FFH
        OUT   PADATA            ; use label from definitions.asm
        
        MVI   A, 1FH                ; PB0..Pb4 inputs, PB5..PB7 outputs
        OUT   PBDIR
        XRA A
        OUT   PBDATA

LOOP:
        ; To check if we can actually store values in RAM
        LXI   H,8200h
        MVI   A,55h
        MOV   M,A         ; write to RAM
        MVI   A,0
        MOV   A,M         ; read back
        CPI   55h
        JNZ   SET_ERR
        MVI   A, 80H
        OUT   PADATA
        JMP   NEXT

SET_ERR:
        MVI   A, 01H
        OUT   PADATA
        
NEXT:
        MVI   B, 255
D1:     DCR   B
        JNZ   D1

        XRA A
        OUT   PADATA

        MVI   B, 255
D2:     DCR   B
        JNZ   D2

        JMP   LOOP

        END
