;
; DataLogger.asm
;
; Created: 29.07.2019 13:35:01
; Author : i_guzak
;


			.include "m32u4def.inc"   ; Используем ATMega328P
			.include "macro.inc"

			.equ RS_N = 4
			.equ RW_N = 7
			.equ ED_N = 6

			.equ RS_P = PORTD
			.equ RW_P = PORTD
			.equ ED_P = PORTD
			.equ DL_P = PORTD
			.equ DH_P = PORTB

			;.equ RS
			;.equ DL_M = 0xF0
			;.equ DH_M = 0x0F
			

;==========================================================
;	RAM
;==========================================================

			.DSEG

			.equ MAXBUFF_IN	 =	10	
			.equ MAXBUFF_OUT = 	10
		
	
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
			RETI		      	
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

	 		.ORG   INT_VECTORS_SIZE      	; Конец таблицы прерываний

;==========================================================
;	TIMER0 OVERFLOW INTERRUPT HANDLER
;==========================================================

;==========================================================
;	RUN
;==========================================================
RESET:   	STACKINIT			; Инициализация стека
			RAMFLUSH			; Очистка памяти

			LDI		R16, 0xFF
			STS		PRR, R16