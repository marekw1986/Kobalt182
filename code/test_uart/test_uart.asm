INCL "definitions.asm"

        ORG   00000H
START:
        ; -------------------------------------------------------
        ; MMU: map ROM 0x00000..0x7FFFF and RAM 0x80000..0xFFFFF
        ; ROMBR   = 0x7F  -> ROM upper boundary (A19..A12 = 0x7F)
        ; RAMLBR  = 0x80  -> RAM lower boundary (A19..A12 = 0x80)
        ; RAMUBR  = 0xFF  -> RAM upper boundary (A19..A12 = 0xFF)
        ; -------------------------------------------------------
        MVI   A, 07FH
        OUT   ROMBR

        MVI   A, 080H
        OUT   RAMLBR

        MVI   A, 0FFH
        OUT   RAMUBR

        ; small settling delay (optional)
        NOP
        NOP

        ; -------------------------------------------------------
        ; Set up stack pointer inside mapped RAM
        ; (16-bit SP; choose an offset inside the mapped RAM window)
        ; -------------------------------------------------------
        LXI   H, 0FFDFH      ; SP = 0xFFDF (top area of your RAM window)
        SPHL

        ; -------------------------------------------------------
        ; UART1: configure baud generator (RLDR1) and enable Tx/Rx
        ; System clock (PHI) = 12.5 MHz (25 MHz crystal / 2)
        ; RLDR = 80 decimal (0x0050) -> ~9645 bps (≈0.5% error)
        ; -------------------------------------------------------
        MVI   A, 050H
        OUT   RLDR1L
        MVI   A, 000H
        OUT   RLDR1H

        ; Enable Receiver (bit0) and Transmitter (bit1) on channel 1
        ; (CNTLB1 bit layout per definitions / datasheet)
        MVI   A, 00000011B
        OUT   CNTLB1

        ; Optionally clear status / FIFOs if your hardware needs it.

MAIN_LOOP:
        MVI   A, 'H'
        CALL  OUT_CHAR
        MVI   A, 'e'
        CALL  OUT_CHAR
        MVI   A, 'l'
        CALL  OUT_CHAR
        MVI   A, 'l'
        CALL  OUT_CHAR
        MVI   A, 'o'
        CALL  OUT_CHAR
        MVI   A, ' '
        CALL  OUT_CHAR
        MVI   A, 'R'
        CALL  OUT_CHAR
        MVI   A, 'X'
        CALL  OUT_CHAR
        MVI   A, '1'
        CALL  OUT_CHAR
        MVI   A, 0DH
        CALL  OUT_CHAR
        MVI   A, 0AH
        CALL  OUT_CHAR

        ; small time-waster loop (16-bit)
        LXI   B, 0FFFFH
DELAY_LOOP:
        DCX   B
        MOV   A, B
        ORA   C
        JNZ   DELAY_LOOP

        JMP   MAIN_LOOP

; -------------------------------------------------------
; OUT_CHAR: send character in A via UART1 (TDR1)
; Waits for Tx ready (STAT1 & TxRDY_MASK) then writes TDR1.
; Requires RAM/stack (CALL/RET).
; -------------------------------------------------------
OUT_CHAR:
        PUSH  PSW
WAIT_TX:
        IN    STAT1
        ANI   TxRDY_MASK
        JZ    WAIT_TX
        POP   PSW
        OUT   TDR1
        RET

; -------------------------------------------------------
; Data areas (placed in RAM window)
; -------------------------------------------------------
        ORG   080000H        ; (symbolic; assembler may treat ORG as 16-bit)
; if your assembler doesn't accept 20-bit ORG, you can keep this
; region at a 16-bit ORG inside the mapped RAM bank as you used before:
;        ORG   8000H
TXTEND: DS    0
VARBGN: DS    55
BUFFER: DS    64
BUFEND: DS    1
BLKDAT: DS    512
SYSTICK:DS    2
RTCTICK:DS    2

        ORG   0FFDFH
STACK:  DS    0

        END
