KBD_DATA            EQU     50H
KBD_STATUS          EQU     51H
KBD_CMD             EQU     51H

TxRDY_MASK   		EQU 	04H
RxRDY_MASK			EQU		01H	

CNTLA0              EQU     00H
CNTLA1              EQU     01H
CNTLB0              EQU     02H
CNTLB1              EQU     03H
STAT0               EQU     04H
STAT1               EQU     05H
TDR0                EQU     06H
TDR1                EQU     07H
TSR0                EQU     08H
TSR1                EQU     09H
BRK0                EQU     12H
BRK1                EQU     13H
CNTR                EQU     0AH
TRDR                EQU     0BH
TMDR0L              EQU     0CH
TMDR0H              EQU     0DH
TMDR1L              EQU     14H
TMDR1H              EQU     15H
RLDR0L              EQU     0EH
RLDR0H              EQU     0FH
RLDR1L              EQU     16H
RLDR1H              EQU     17H
TCR                 EQU     10H
FRC                 EQU     18H
CCR                 EQU     1FH
SAR0L               EQU     20H
SAR0H               EQU     21H
SAR0B               EQU     22H
DAR0L               EQU     23H
DAR0H               EQU     24H
DAR0B               EQU     25H
BCR0L               EQU     26H
BCR0H               EQU     27H
MAR1L               EQU     28H
MAR1H               EQU     29H
MAR1B               EQU     2AH
IAR1L               EQU     2BH
IAR1H               EQU     2CH
BCR1L               EQU     2EH
BCR1H               EQU     2FH
DSTAT               EQU     30H
DMODE               EQU     31H
DCNTL               EQU     32H
CBR                 EQU     38H
BBR                 EQU     39H
CBAR                EQU     3AH
IL                  EQU     33H
ITC                 EQU     34H
RCR                 EQU     36H
OMCR                EQU     3EH
ICR                 EQU     3FH

ESCC_A_CTRL         EQU     0E0H
ESCC_A_DATA         EQU     0E1H
ESCC_B_CTRL         EQU     0E2H
ESCC_B_DATA         EQU     0E3H

PADIR               EQU     0EDH
PADATA              EQU     0EEH

PBDIR               EQU     0E4H
PBDATA              EQU     0E5H

PCDIR               EQU     0DDH
PCDATA              EQU     0DEH

SCR                 EQU     0EFH        ; System confoguration register
RAMUBR              EQU     0E6H
RAMLBR              EQU     0E7H
ROMBR               EQU     0E8H
WSG                 EQU     0D8H        ; Wait state generator
IEPMR               EQU     0DFH        ; Interrupt edge/pin mux register
MMC                 EQU     0FFH        ; MIMIC master control register
IUS_IP              EQU     0FEH
IE_REG              EQU     0FDH
IVEC                EQU     0FCH        ; Interrupt vector

; CF REGS
CFBASE              EQU     0E0H
CFREG0              EQU     CFBASE+0	;DATA PORT
CFREG1              EQU     CFBASE+1	;READ: ERROR CODE, WRITE: FEATURE
CFREG2              EQU     CFBASE+2	;NUMBER OF SECTORS TO TRANSFER
CFREG3              EQU     CFBASE+3	;SECTOR ADDRESS LBA 0 [0:7]
CFREG4              EQU     CFBASE+4	;SECTOR ADDRESS LBA 1 [8:15]
CFREG5              EQU     CFBASE+5	;SECTOR ADDRESS LBA 2 [16:23]
CFREG6              EQU     CFBASE+6	;SECTOR ADDRESS LBA 3 [24:27 (LSB)]
CFREG7              EQU     CFBASE+7	;READ: STATUS, WRITE: COMMAND

LOAD_BASE			EQU		0DC00H
BIOS_ADDR			EQU		LOAD_BASE+1600H

CR      EQU  0DH
LF      EQU  0AH
