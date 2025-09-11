STACK EQU 0FFE0H

		INCL "../common/definitions.asm"

        ORG  0000H
START:  
        JMP  INIT

		INCL "../common/cf.asm"
		INCL "keyboard.asm"
		INCL "../common/utils.asm"
		INCL "../common/hexdump.asm"

        ;Set SYSTICK, RTCTICK and KBDDATA to 0x00
INIT:   LXI  H, 0000H
        SHLD SYSTICK
        LXI  H, 0000H
        SHLD RTCTICK
        MVI A, 00H
        STA  KBDDATA
        
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
        MVI   A, 00h           ; Rx disabled
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

        ; Wait before initializing CF card
		MVI C, 255
		CALL DELAY
        MVI C, 255
		CALL DELAY
		MVI C, 255
		CALL DELAY
		MVI C, 255
		CALL DELAY
        
		CALL IPUTS
		DB 'CF CARD: '
		DB 00H
		CALL CFINIT
		CPI 00H								; Check if CF_WAIT during initialization timeouted
		JZ GET_CFINFO
		CALL IPUTS
		DB 'missing'
		DB 00H
		CALL NEWLINE
		JMP $
GET_CFINFO:
        CALL CFINFO
        CALL IPUTS
        DB 'Received MBR: '
        DB 00H
        CALL CFGETMBR
        ; HEXDUMP MBR - START
        ;LXI D, LOAD_BASE
        ;MVI B, 128
        ;CALL HEXDUMP
        ;LXI D, LOAD_BASE+128
        ;MVI B, 128
        ;CALL HEXDUMP
        ;LXI D, LOAD_BASE+256
        ;MVI B, 128
        ;CALL HEXDUMP
        ;LXI D, LOAD_BASE+384
        ;MVI B, 128
        ;CALL HEXDUMP
        ;CALL NEWLINE
        ; HEXDUMP MBR - END
        ; Check if MBR is proper
        LXI D, LOAD_BASE+510
        LDAX D
        CPI 55H
        JNZ LOG_FAULTY_MBR
        INX D
        LDAX D
        CPI 0AAH
        JNZ LOG_FAULTY_MBR
        JMP LOG_PARTITION_TABLE
LOG_FAULTY_MBR:
		CALL IPUTS
		DB 'ERROR: faulty MBR'
		DB 00H
		CALL NEWLINE
        JMP $
LOG_PARTITION_TABLE:
		CALL IPUTS
		DB 'Partition table'
		DB 00H
        CALL NEWLINE
        CALL PRN_PARTITION_TABLE
        CALL NEWLINE
        ; Check if partition 1 is present
        LXI D, LOAD_BASE+446+8		; Address of first partition
        CALL ISZERO32BIT
        JNZ CHECK_PARTITION1_SIZE
        CALL IPUTS
		DB 'ERROR: partition 1 missing'
		DB 00H
        CALL NEWLINE
        JMP $
CHECK_PARTITION1_SIZE:
		; Check if partition 1 is larger than 16kB (32 sectors)
		LXI D, LOAD_BASE+446+12		; First partition size
		LDAX D
		CPI 32						; Check least significant byte
		JZ BOOT_CPM ;PRINT_BOOT_OPTIONS		; It is equal. Good enough.
		JNC BOOT_CPM ;PRINT_BOOT_OPTIONS		; It is bigger
		INX D
		LDAX D
		CPI 00H
		JNZ BOOT_CPM ;PRINT_BOOT_OPTIONS
		INX D
		LDAX D
		CPI 00H
		JNZ BOOT_CPM ;PRINT_BOOT_OPTIONS
		INX D
		LDAX D
		CPI 00H
		JNZ BOOT_CPM ;PRINT_BOOT_OPTIONS
		CALL IPUTS
		DB 'ERROR: partition 1 < 16kB'
		DB 00H
		CALL NEWLINE
		JMP $
        
BOOT_CPM:
		DI
        CALL LOAD_PARTITION1
        CPI 00H
        JZ JUMP_TO_CPM
        CALL IPUTS
        DB 'CP/M load error. Reset.'
        DB 00H
        CALL ENDLESS_LOOP
JUMP_TO_CPM:
        CALL NEWLINE
        CALL IPUTS
        DB 'Load successfull.'
        DB 00H
        CALL NEWLINE
        JMP BIOS_ADDR
        
CFERRM: DB   'CF ERROR: '
        DB   CR
STARTADDRSTR:
		DB	 'Addr: '
		DB	 CR
SIZESTR:
		DB	 'Size: '
		DB	 CR

		INCL "fonts1.asm"
		INCL "ps2_scancodes.asm"

;       ORG  1366H
;       ORG  1F00H
		ORG	 0FBDFH
SYSTEM_VARIABLES:
BLKDAT: DS   512                        ;BUFFER FOR SECTOR TRANSFER
BLKENDL DS   0                          ;BUFFER ENDS
CFLBA3	DS	 1
CFLBA2	DS	 1
CFLBA1	DS	 1
CFLBA0	DS	 1                          
SYSTICK DS   2                          ;Systick timer
RTCTICK DS   2							;RTC tick timer/uptime
KBDDATA DS   1                          ;Keyboard last received code
KBDKRFL DS	 1							;Keyboard key release flag
KBDSFFL DS	 1							;Keyboard Shift flag
KBDOLD	DS	 1							;Keyboard old data
KBDNEW	DS	 1							;Keyboard new data
STKLMT: DS   1                          ;TOP LIMIT FOR STACK

CR      EQU  0DH
LF      EQU  0AH

        END
