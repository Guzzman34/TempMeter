;
; DataLogger.asm
;
; Created: 29.07.2019 13:35:01
; Author : i_guzak
;


			.include "m32u4def.inc"   ; ���������� ATMega328P
			.include "macro.inc"

			.equ	RS_N = 4
			.equ	RW_N = 7
			.equ	ED_N = 6

			.equ	RS_P = PORTD
			.equ	RW_P = PORTD
			.equ	ED_P = PORTD
			.equ	CTRL = PORTD
			.equ	DL_P = PORTD
			.equ	DH_P = PORTB

			.equ	DELAY_001 = 0x02	;OCR1A - delay to 1 us
			.equ	DELAY_050 = 0x04	;OCR1B - delay to 50 us
			.equ	DELAY_120 = 0x08	;OCR1C - delay to 120 us or other duration
			.equ	DL_CN_001 = 16
			.equ	DL_CN_050 = 800
			.equ	DL_CN_120 = 1920
;			.equ	DL_STEP = 0,0625	;no prescaling

			.equ	DCEFS = 0b00110110	;extended command set
			.equ	DCCLR = 0b00000001	;clear display

			;.equ RS
			;.equ DL_M = 0x0F
			;.equ DH_M = 0x0F
			

;==========================================================
;	RAM
;==========================================================

			.DSEG

			.equ MAXBUFF_IN	 =	10	
			.equ MAXBUFF_OUT = 	10
		

DL_FLAGS:	.byte	1
IN_BUFF:	.byte	MAXBUFF_IN
IN_PTR_S:	.byte	1
IN_PTR_E:	.byte	1
IN_FULL:	.byte	1	

OUT_BUFF:	.byte	MAXBUFF_OUT
OUT_PTR_S:	.byte	1
OUT_PTR_E:	.byte	1
OUT_FULL:	.byte	1

;==========================================================
;	FLASH
;==========================================================

			.CSEG
			.ORG $0000        	; (RESET) 
			RJMP   Reset
			.ORG $0002			; (INT0) External Interrupt Request 0
			RETI             	
			.ORG $0004			; (INT1) External Interrupt Request 1
			RETI    
			.ORG $0006			; (INT2) External Interrupt Request 2
			RETI           	
			.ORG $0008			; (INT3) External Interrupt Request 3
			RETI  
			.ORG $000A			; Reserved
			RETI  
			.ORG $000C			; Reserved
			RETI  
			.ORG $000E			; (INT6) External Interrupt Request 6
			RETI  
			.ORG $0010			; Reserved
			RETI  
			.ORG $0012			; (PCINT0) Pin change interrupt request 0
			RETI		      	
			.ORG $0014			; (USB General) USB General Interrupt request
			RETI             	
			.ORG $0016			; (USB Endpoint) USB Endpoint Interrupt request
			RETI		      	
			.ORG $0018			; (WDT) Watchdog time-out interrupt
			RETI			  	
			.ORG $001A			; Reserved
			RETI  
			.ORG $001C			; Reserved
			RETI  
			.ORG $001E			; Reserved
			RETI  
			.ORG $0020			; (TIMER1 CAPT) Timer/Counter1 Capture Event
			RETI             	
			.ORG $0022			; (TIMER1 COMPA) Timer/Counter1 Compare Match A
			RETI	  			
			.ORG $0024			; (TIMER1 COMPB) Timer/Counter1 Compare Match B
			RETI	
			.ORG $0026			; (TIMER1 COMPC) Timer/Counter1 Compare Match C
			RETI	        
			.ORG $0028			; (TIMER1 OVF) Timer/Counter1 Overflow
			RJMP T1_OVF		      	
			.ORG $002A			; (TIMER0 COMPA) Timer/Counter0 Compare Match A
			RETI		      	
			.ORG $002C			; (TIMER0 COMPB) Timer/Counter0 Compare Match B
			RETI             	
			.ORG $002E			; (TIMER0 OVF) Timer/Counter0 Overflow
			RETI             	
			.ORG $0030			; (SPI,STC) Serial Transfer Complete
			RETI             	
			.ORG $0032			; (USART,RXC) USART, Rx Complete
			RETI             	
			.ORG $0034			; (USART,UDRE) USART Data Register Empty
			RETI             	
			.ORG $0036			; (USART,TXC) USART, Tx Complete
			RETI       
			.ORG $0038			; (ANA_COMP) Analog Comparator
			RETI      	
			.ORG $003A			; (ADC) ADC Conversion Complete
			RETI
			.ORG $003C			; (EE_RDY) EEPROM Ready
			RETI
			.ORG $003E			; (TIMER3 CAPT) Timer/Counter3 Capture Event
			RETI             	
			.ORG $0040			; (TIMER3 COMPA) Timer/Counter3 Compare Match A
			RETI	  			
			.ORG $0042			; (TIMER3 COMPB) Timer/Counter3 Compare Match B
			RETI	
			.ORG $0044			; (TIMER3 COMPC) Timer/Counter3 Compare Match C
			RETI	        
			.ORG $0046			; (TIMER3 OVF) Timer/Counter3 Overflow
			RETI		      	
			.ORG $0048			; (TWI) 2-wire Serial Interface
			RETI
			.ORG $004A			; (SPM_RDY) Store Program Memory Ready
			RETI
			.ORG $004C			; (TIMER4 COMPA) Timer/Counter4 Compare Match A
			RETI	  			
			.ORG $004E			; (TIMER4 COMPB) Timer/Counter4 Compare Match B
			RETI	
			.ORG $0050			; (TIMER4 COMPC) Timer/Counter4 Compare Match C
			RETI	        
			.ORG $0052			; (TIMER4 OVF) Timer/Counter4 Overflow
			RETI	
			.ORG $0054			; (TIMER4 FPF) Timer/Counter4 Fault Protection Interrupt
			RETI	      	

	 		.ORG   INT_VECTORS_SIZE      	; ����� ������� ����������


;==========================================================
;	TIMER1 OVERFLOW INTERUPT HANDLER
;==========================================================

T1_OVF:		NOP
			NOP
			RETI

;==========================================================
;	DELAY FUNCTION
;==========================================================

;R16 � ���������� ������ ��������
DELAY_US:	DEC		R16			;��������.
			CPI		R16, 0		;�����������?
			BRNE	DELAY_US    ;��� - ��� ���.             
			RET

;==========================================================
;	COMMAND OUT FUNCTION
;==========================================================
;R16 - local register
;R17 - command code
CMD_OUT:	CBI		CTRL, ED_N
			CBI		CTRL, RS_N
			CBI		CTRL, RW_N

			LDI		R16, DL_CN_001
			RCALL	DELAY_US

			SBI		CTRL, ED_N
			DSET

			LDI		R16, DL_CN_001
			RCALL	DELAY_US

			CBI		CTRL, ED_N

			LDI		R16, DL_CN_050
			RCALL	DELAY_US
			RET

;==========================================================
;	DATA OUT FUNCTION
;==========================================================

;R16 - local register
;R17 - data
DAT_OUT:	CBI		CTRL, ED_N
			SBI		CTRL, RS_N
			CBI		CTRL, RW_N

			LDI		R16, DL_CN_001
			RCALL	DELAY_US

			SBI		CTRL, ED_N
			DSET

			LDI		R16, DL_CN_001
			RCALL	DELAY_US

			CBI		CTRL, ED_N

			LDI		R16, DL_CN_050
			RCALL	DELAY_US
			RET

;==========================================================
;	REGISTRATION DELAYS FUNCTION
;==========================================================

; R16 - 1-255
; R17 - units (us, ms, s)
;REG_DL:		PUSHF
;			PUSH	R17
;			PUSH	R18
;			PUSH	X

;			POP		X
;			POP		R18
;			POP		R17
;			POPF
;			RET

;==========================================================
;	RUN
;==========================================================
RESET:   	STACKINIT			; ������������� �����
			RAMFLUSH			; ������� ������

			LDI		R16, 0xFF
			STS		PRR, R16

;==========================================================
;	TIMER 1 INIT
;==========================================================

/*			CLR		R16
			TCCR1A	OUT, R16	;pin - disconnect, mode - 0
			LDI		R16, 0x01
			TCCR1B	OUT, R16	;clock - no prescaling
			CLR		R16
			TCCR1C	OUT, R16

			;set 1 us delay - write 16(0x0010) in register OCR1A
			LDI		R16, 0x10
			LDI		R17, 0x00
			OUT		OCR1AH, R17
			OUT		OCR1AL, R16

			;set 50 us delay - write 800(0x0320) in register OCR1B
			LDI		R16, 0x20
			LDI		R17, 0x03
			OUT		OCR1BH, R17
			OUT		OCR1BL, R16

			;set 120 us delay - write 1920(0x0780) in register OCR1C
			LDI		R16, 0x80
			LDI		R17, 0x07
			OUT		OCR1CH, R17
			OUT		OCR1CL, R16*/

			;enable overflow interrupt
			;------------||   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0    ||
			;---TIMSK1---||   -   |   -   | ICIE1 |   -   | OCIE1C| OCIE1B| OCIE1A|  TOIE1 ||
			;LDI		R16, 0x01
			;OUT		TIMSK1, R16

;==========================================================
;	DISPLAY LCD12864 (ST7920) INIT
;==========================================================

			;ATMEGA32U4
			;D0 - PD0
			;D1 - PD1
			;D2 - PD2
			;D3 - PD3
			;D4 - PB4
			;D5 - PB5
			;D6 - PB6
			;D7 - PB7
			;ED - PD4
			;RW - PD7
			;RS - PD6

			;set port D
			LDI		R16, 0xFF
			OUT		PORTD, R16

			;set port B
			LDI		R16, 0xFF
			OUT		PORTB, R16

			;delay 50 us
			LDI		R16, DL_CN_050
			RCALL	DELAY_US

			LDI		R17, DCEFS
			RCALL	CMD_OUT

;==========================================================
;	MAIN LOOP
;==========================================================

LOOP:		NOP
			NOP
			RJMP	LOOP
			;IN		R16, TCNT1L
			;IN		R17, TCNT1H
			;LDS		R18, DL_FLAGS
			;MOV		R17, R16
			;ANDI	R16, DELAY_050
			;BRNE	OUT_DL_050
			//Work with delay 50 us

			;clear bit of the end of the delay 50 us
			;MOV		R16, R17
			;CBR		R16, DELAY_050
			;STS		DL_FLAGS, R16



			//End work with delay 50 us
;OUT_DL_050:	MOV		R16, R17
;			ANDI	R16, DELAY_120
;			BRNE	OUT_DL_120
			//Work with delay 120 us
;OUT_DL_120:	NOP

;			RJMP	LOOP

;SCRNDT1:=	.dw		

			




