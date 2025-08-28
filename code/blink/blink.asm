        INCL "../common/definitions.asm"

        ORG   0000H
START:  
        ; ----------------------------
        ; Init PIO Port C
        ; ----------------------------
		; Set Port C to GPIO (parallel)
        MVI   A, 80H      ; SCR bit 7 = 1, other bits = 0
        OUT   SCR         ; Use definitions.asm to define SCR
        ; Configure only PC5 as output (others remain inputs)
        MVI   A, 20H          ; bit5 = 1 → PC5 output
        OUT   OMCR            ; use label from definitions.asm

        ; Ensure PC5 low
        MVI   A, 00H
        OUT   ICR             ; use label from definitions.asm

; ----------------------------
; Blink loop on PC5
; ----------------------------
LOOP:   
        ; ---- set PC5 high ----
        MVI   A, 20H          ; bit5 = 1
        OUT   ICR

        ; inline delay
        MVI   C, 0FFH
DLY1:   DCR   C
        JNZ   DLY1

        ; ---- set PC5 low ----
        MVI   A, 00H
        OUT   ICR

        ; inline delay
        MVI   C, 0FFH
DLY2:   DCR   C
        JNZ   DLY2

        JMP   LOOP

        END
