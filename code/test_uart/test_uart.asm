        INCL "../common/definitions.asm"

CONTROL  EQU 0E0H    ; ESCC Channel A control register (WRx/RR0 etc.)
DATA     EQU 0E1H    ; ESCC Channel A data (TDR/RDR)
TxRDY    EQU 04H    ; Bit 2 of RR0 = Transmit Buffer Empty

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
        mvi   a, 09h           ; WR9 (Reset and interrupt control)
        out   CONTROL
        mvi   a, 0C0h          ; Reset Channel A + Tx underrun
        out   CONTROL

; --- Async mode (8N1) ---
        mvi   a, 04h           ; Select WR4
        out   CONTROL
        mvi   a, 44h          ; 16× clock, 1 stop bit, 8 bits, async
        out   CONTROL

; --- Disable Rx (clear receiver parameters) ---
        mvi   a, 03h           ; Select WR3
        out   CONTROL
        mvi   a, 00h           ; Rx disabled
        ;mvi	  a, 01h		   ; Rx enabled
        out   CONTROL

; --- Enable Tx (and RTS) ---
        mvi   a, 05h           ; Select WR5
        out   CONTROL
        mvi   a, 0EAh          ; Tx enable, RTS, DTR 8-bit — 1110 1010b
        out   CONTROL

; --- Baud rate generator (BRG) setup ---
        ; Divisor ≈ 651 for 9600 baud @ 12.5 MHz clock
        mvi   a, 0Ch           ; Select WR12 (BRG low byte)
        out   CONTROL
        mvi   a, 08Bh          ; Low byte = 0x8B (139)
        out   CONTROL

        mvi   a, 0Dh           ; Select WR13 (BRG high byte)
        out   CONTROL
        mvi   a, 02h           ; High byte = 0x02 (2)
        out   CONTROL

        mvi   a, 0Eh           ; Select WR14 (BRG control)
        out   CONTROL
        mvi   a, 03h           ; Enable BRG and set clock source
        out   CONTROL

LOOP:

WAIT_TX:
        in    CONTROL           ; Read RR0 status
        ani   TxRDY            ; Check Tx buffer empty flag
        jz    WAIT_TX

        mvi   a, 055h          ; Data to send
        out   DATA             ; Write to transmit data port
        

        JMP   LOOP

        END
