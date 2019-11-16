;**************************************************************************
;			    8 SEQUENTIAL LEDs
;**************************************************************************
; Aim:
;   - Blink 8 LEDs sequentially.
;
; Objectives:
;   1. Blink the LEDs sequentially: blink RB0, then RB1 ..., then RB7,
;      then RB0 then RB1, then ...
;   2. Each LED should turn on for 1 second and then off for 1 second,
;      before blinking the next LED.
;
; Setup:
;   - An LED and series resistor are connected to each pin RB0 to RB7.
;**************************************************************************

#include <p16f877.inc>

;--------------------------------------------------------------------------
; Set Configuration Bits (Disable Watchdog Timer)
;--------------------------------------------------------------------------
; CONFIG
; __config 0xFFFB
 __CONFIG _FOSC_EXTRC & _WDTE_OFF & _PWRTE_OFF & _CP_OFF & _BOREN_ON & _LVP_ON & _CPD_OFF & _WRT_ON


;--------------------------------------------------------------------------
; Program Code
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
;   Set the reset vector here.
;--------------------------------------------------------------------------

		org	    0x0000
		goto	    start

;--------------------------------------------------------------------------
;			    DELAY SUBROUTINES
;--------------------------------------------------------------------------
;
; Operating speed:  DC, 20 MHz clock input
;		    DC, 200 ns instruction cycle
;--------------------------------------------------------------------------

		org	    0x0005

;--------------------------------------------------------------------------
;			    100us Delay
;--------------------------------------------------------------------------
; Counter Setup = (1[movlw] +1[movwf]) x 200ns = 400ns
; Last Cycle of Loop Time = (1[decfsz] + 1[skip] + 2[return]) x 200ns = 800ns
; Calling delay100us =  2 cycles x 200ns = 400ns
;
; Setup Time = 400ns + 800ns + 400ns = 1600ns
;
; Remaining Time = 1us - Setup Time = 100000ns - 1600ns = 98400ns
;
; Loop Cycle Time (not for last cycle) = (1[decfsz] + 2[goto]) x 200ns = 600ns
;
; Remaining Time = (Count100us - 1) x Loop Cycle Time
; 98400ns = (Count100us - 1) x 600ns
;
; Hence, Count100us = 164 + 1 = 165
;--------------------------------------------------------------------------
Count100us	equ	    0x20

delay100us	movlw	    d'165'	    ; Load d'165' into W		    (1 cycle)
		movwf	    Count100us	    ; Move W into Count100us		    (1 cycle)

again100us	decfsz	    Count100us	    ; Decrement, test if Count100us = 0?    (1 cycle)
		goto	    again100us	    ; NO => Keep waiting		    (2 cycles)
					    ; Skip				    (1 cycle)
		return			    ; YES => Return			    (2 cycles)

;--------------------------------------------------------------------------
;			    39600ns Delay
;--------------------------------------------------------------------------
; Count 39600ns for the extra fractional part of the remaining time
;
; Counter Setup = (1[movlw] + 1[movwf] + 1[nop]) x 200ns = 600ns
; Last Cycle of Loop Time = (1[decfsz] + 1[skip] + 2[return]) x 200ns = 800ns
; Calling delay39600ns =  2 cycles x 200ns = 400ns
;
; Setup Time = 600ns + 800ns + 400ns = 1800ns
;
; Remaining Time = 39600ns - Setup Time = 39600ns - 1800ns = 37800ns
;
; Loop Cycle Time (not for last cycle) = (1[decfsz] + 2[goto]) x 200ns = 600ns
;
; Remaining Time = (Count39600ns - 1) x Loop Cycle Time
; 37800ns = C(ount39600ns - 1) x 600ns
;
; Hence, Count39600ns = 63 + 1 = 64
;--------------------------------------------------------------------------
Count39600ns	equ	    0x21

delay39600ns	movlw	    d'64'	    ; Load d'64' into W			    (1 cycle)
		movwf	    Count39600ns    ; Move W into Count39600ns		    (1 cycle)
		nop			    ; (1 cycle)

again39600ns	decfsz	    Count39600ns    ; Decrement, test if Count39600nss = 0? (1 cycle)
		goto	    again39600ns    ; NO => Keep waiting		    (2 cycles)
					    ; Skip				    (1 cycle)
		return			    ; YES => Return			    (2 cycles)

;--------------------------------------------------------------------------
;			    10ms Delay
;--------------------------------------------------------------------------
; Counter Setup = (1[movlw] +1[movwf]) x 200ns = 400ns
; Last Cycle of Loop Time = 100000ns + (1[decfsz] + 1[skip] + 2[return]) x 200ns + 39600ns = 140400ns
; Calling delay10ms =  2 cycles x 200ns = 400ns
;
; Setup Time = 400ns + 140400ns + 400ns = 141200ns
;
; Remaining Time = 10ms - Setup Time = 10000000ns - 141200ns = 9858800ns
;
; Loop Cycle Time (not for last cycle) = 100000ns + (1[decfsz] + 2[goto]) x 200ns = 100600ns
;
; Remaining Time = (Count10ms - 1) x Loop Cycle Time
; 9858800ns = (Count10ms - 1) x 100600ns
;
; Hence, Count10ms = 98 + 1 = 99
;--------------------------------------------------------------------------
Count10ms	equ	    0x22

delay10ms	movlw	    d'99'	    ; Load d'99' into W			    (1 cycle)
		movwf	    Count10ms	    ; Move W into Count10ms		    (1 cycle)

again10ms	call	    delay100us
		decfsz	    Count10ms	    ; Decrement, test if Count10ms = 0?	    (1 cycle)
		goto	    again10ms	    ; NO => Keep waiting		    (2 cycles)
					    ; Skip				    (1 cycle)
		call	    delay39600ns    ; YES => Delay for 39600ns more
		return			    ; Return				    (2 cycles)

;--------------------------------------------------------------------------
;			    9939600ns Delay
;--------------------------------------------------------------------------
; Counter Setup = (1[movlw] + 1[movwf]) x 200ns = 400ns
; Last Cycle of Loop Time = 100000ns + (1[decfsz] + 1[skip] + 2[return]) x 200ns = 100800ns
; Calling delay9939600ns =  2 cycles x 200ns = 400ns
;
; Setup Time = 400ns + 100800ns + 400ns = 101600ns
;
; Remaining Time = 9939600ns - Setup Time = 9939600ns - 101600ns = 9838000ns
;
; Loop Cycle Time (not for last cycle) = 100000ns + (1[decfsz] + 2[goto]) x 200ns = 100600ns
;
; Remaining Time = (Count9939600ns - 1) x Loop Cycle Time
; 9838000ns = (Count9939600ns - 1) x 100600ns
; Hence, Count9939600ns = 97.7932405567 + 1 = 98.7932405567 = 98
;
; Fractional Time = 9838000ns - (100600ns x 97)
;		  = 79800ns
;		  = (2 x 39600ns) + (3 x 200ns)
;		  = 2 calls to delay39600ns and 3 nop's
;--------------------------------------------------------------------------
Count9939600ns	equ	    0x23

delay9939600ns	movlw	    d'98'	    ; Load d'98' into W			    (1 cycle)
		movwf	    Count9939600ns  ; Move W into Count9939600ns	    (1 cycle)

again9939600ns	call	    delay100us
		decfsz	    Count9939600ns  ; Decrement, test if Count9939600ns = 0?(1 cycle)
		goto	    again9939600ns  ; NO => Keep waiting		    (2 cycles)
					    ; Skip				    (1 cycle)
		call	    delay39600ns    ; YES => Delay for 79800ns more
		call	    delay39600ns
		nop			    ;					    (1 cycle)
		nop			    ;					    (1 cycle)
		nop			    ;					    (1 cycle)

		return			    ; Return				    (2 cycles)

;--------------------------------------------------------------------------
;			    1s Delay
;--------------------------------------------------------------------------
; Counter Setup = (1[movlw] +1[movwf]) x 200ns = 400ns
; Last Cycle of Loop Time = 10000000ns + (1[decfsz] + 1[skip] + 2[return]) x 200ns + 9939600ns = 19940400ns
; Calling delay10ms =  2 cycles x 200ns = 400ns
;
; Setup Time = 400ns + 19940400ns + 400ns = 19941200ns
;
; Remaining Time = 1s - Setup Time = 1000000000ns - 19941200ns = 980058800ns
;
; Loop Cycle Time (not for last cycle) = 10000000ns + (1[decfsz] + 2[goto]) x 200ns = 10000600ns
;
; Remaining Time = (Count1s - 1) x Loop Cycle Time
; 980058800ns = (Count1s - 1) x 10000600ns
;
; Hence, Count1s = 98 + 1 = 99
;--------------------------------------------------------------------------
Count1s		equ	    0x24

delay1s		movlw	    d'99'	    ; Load d'99' into W			    (1 cycle)
		movwf	    Count1s	    ; Move W into Count1s		    (1 cycle)

again1s		call	    delay10ms
		decfsz	    Count1s	    ; Decrement, test if Count1s = 0?	    (1 cycle)
		goto	    again1s	    ; NO => Keep waiting		    (2 cycles)
					    ; Skip				    (1 cycle)
		call	    delay9939600ns  ; YES => Delay for 9939600ns
		return			    ; Return				    (2 cycles)

;--------------------------------------------------------------------------
;		Subroutine for Blinking 8 LEDs Sequentially
; Blinks the 8 LEDs in sequence from RB0 to RB7 with 1s delays
;--------------------------------------------------------------------------
LitLED		equ	    0x25

sequential_blink
		movlw	    b'00000001'	    ; Load b'00000001' into W
		movwf	    LitLED	    ; Move W into LitLED

again8		movf	    LitLED, 0	    ; Move LitLED to W
		movwf	    PORTB	    ; Turn on LED
		call	    delay1s	    ; for 1 second
		movlw	    0x00	    ; Load 0x00 into W
		movwf	    PORTB	    ; Turn off LED
		call	    delay1s	    ; for 1 second
		bcf	    STATUS, C	    ; Ensure carry is clear before rotating
		rlf	    LitLED	    ; Set next LED pin
		movlw	    b'00000000'	    ; Load b'00000000' into W
		xorwf	    LitLED, 0	    ; Cycled through all 8 LEDs?
		btfss	    STATUS, Z	    ; YES => Skip next instruction
		goto	    again8	    ; NO => Blink next LED
		return			    ; Return

;--------------------------------------------------------------------------
; Main Program - Blinking 8 LEDs sequentially
;--------------------------------------------------------------------------
start		bsf	    STATUS, RP0	    ; Select Bank 1
		movlw	    0x00	    ; Load 0x00 in W
		movwf	    TRISB	    ; Set all pins of PORTB as OUTPUTs
		bcf	    STATUS, RP0	    ; Select Bank 0

keep_blinking	call	    sequential_blink
		goto	    keep_blinking

		end
