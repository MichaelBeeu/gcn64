/*
 * n64.inc
 *
 *  Created: 11/1/2013 1:50:31 AM
 *   Author: Owner
 */ 

 .equ N64_DDR   = DDRD
 .equ N64_PIN   = PIND
 .equ N64_PORT  = PORTD
 .equ N64_DATA  = PD2

 ; High bit:
;              ___
;  ___ ___ ___/
; ^     3us   ^1us^
; Low bit:
; 
;      ___ ___ ___
;  ___/
; ^1us^    3us    ^
; Each byte is 8 bits. There is also a single high stop bit at the end of a stream of bits.

;         1-8  |  9-16 | 17-24 | 25-32 |
; Low : _______ _______ _______ -------
; High: _______ ------- ------- -------

 ; r25 - Data
 ; Clobbers r20, r21, r22.
 ; T flag is set when a whole byte is received
 ; Called on the falling edge of the data line.
 n64_int:
     ; The AVR could have taken 8-11 cycles to get here, after the line went low
	 ; (thats 1 - 1.375 us!) Which means that if the bit is 1, the data line
	 ; has probably already gone high, but if the bit is 0, it should still be low.
	 ; but it shouldn't really matter because we're going to time how long it takes
	 ; to go high.

	 ; A bit from the n64 takes about 32 clock cyles.

	 ; I probably could read 9 bits, and check if the last bit
	 ; is high, then shift the register back, but reading only 8
	 ; bits seems to reliably enough.
	 ldi r20, 8      ; 1
	 in r21, SREG    ; 1
	 
	 n64_read_bit:
	     ; Count time it takes for line to go high
		 clr r22                ; Clear counter
	     n64_time_bit:
		     inc r22
			 sbis N64_PIN, N64_DATA
			 rjmp n64_time_bit
		 ; A high bit should only go through the loop once
		 cpi r22, 2     ; Carry will be set if r22 is lower than 2, and unset if r22 is greater or equal
		 rol r25        ; roll carry into lsb of register

		 ; Wait for line to go low
		 ; TODO: Everything seems to work fine, but should there be a timeout here?
		 n64_read_wait_low:
		     sbic N64_PIN, N64_DATA
			 rjmp n64_read_wait_low
		 
		 dec r20
		 breq n64_done_reading

		 rjmp pc+1
		 rjmp pc+1

		 nop
		 rjmp n64_read_bit

	n64_done_reading:
		sbi PORTD, PD4 ; Debug LED
		sbr r21, 0x40 ; set T  flag
		push r21

		; Process N64 commands here, so we can be sure the N64 gets a
		; response quickly

		; Cmd: 0x00 - Controller ID, expansion packs.
		cpi r25, 0x00
		brne not_0x00
		send_ident:
		    ldi ZH, HIGH( n64_ident_buf )
			ldi ZL, LOW ( n64_ident_buf )

			ldi r18, 3
			rcall n64_send_8mhz
			rjmp main_loop
		not_0x00:
		; Cmd: 0xff - Reset, send ID
		; We don't actually reset anything, but for completeness we send the ID bytes
		; in case any games require it.
		cpi r25, 0xff
		breq send_ident
		; Cmd: 0x01 - Get controller data

		; TODO: Compare command, this seemed to break the response.
		;cpi r25, 0x01
		;brne n64_skip_send

		ldi ZH, HIGH( n64_buf )
		ldi ZL, LOW ( n64_buf )

		ldi r18, 4
		rcall n64_send_8mhz

	n64_skip_send:
		pop r21
	n64_read_timeout:
	    ; Unset INT0 flag, which was probably set while we
		; were receiving/sending data
	    ldi r16, (1<<INT0)
		out EIFR, r16
		; Restore registers
		; TODO: This might not be necessary anymore.
		out SREG, r21
		; Debug LED
		cbi PORTD, PD4
		reti

	; Z - pointer to data to send
	; r18 - Number of bytes to send
	; clobbers r21, r20
n64_send_8mhz:
	; Assumes 8mhz clock
	cli

	; Instead of counting down the bits, we count up by 32, but still use
	; the Z flag for branching--this saves a clock cycle in the
	; byte-send loop.
	ldi r20, 32
	mov r0, r20
	ldi r20, 0
	n64_send_bytes_loop_8mhz:
		ld r21, Z+   ;                  | 2
		n64_send_bits_loop_8mhz:
			sbi N64_DDR, N64_DATA ;      | 2
		    lsl r21   ; Shift msb into C | 1
			brcc n64_send_bit_low_8mhz ; | 1 if false
			                           ; | 2 if true
		    ; Send high bit
			; timing: 1 us low, 3 us high
			; we're at 2/8 clocks needed for low
			rjmp pc+1
			rjmp pc+1
			cbi N64_DDR, N64_DATA ;     | 2
			rcall wait_1us_8mhz   ;     | 8
			rjmp pc+1
			rjmp pc+1
			nop
			;rjmp pc+1             ;       | 6
			rjmp n64_send_bit_cont_8mhz ; | 2
			                            ; 8 clocks left over
		n64_send_bit_low_8mhz:
		    ; Send low bit
			; timing: 3 us low, 1 us high
			; we're at 4/24 clocks needed for low
			nop
			rjmp pc+1
			rcall wait_1us_8mhz   ;    | 8
			nop
			rjmp pc+1
			rjmp pc+1
			rjmp pc+1
			cbi N64_DDR, N64_DATA ;    | 2
			                      ; 8 clocks left over
		n64_send_bit_cont_8mhz: ; 6 clocks left to use (after loading the next bit, and branching)
		                        ; 5 clocks left to use if we need to load the next byte
		add r20, r0               ;    | 1
		breq n64_send_next_byte   ;    | 1 if false
		                          ;    | 2 if true
		rjmp pc+1
		rjmp n64_send_bits_loop_8mhz ; | 2
	n64_send_next_byte:
	dec r18                       ;    | 1
	brne n64_send_bytes_loop_8mhz ;    | 1 if false
	                              ;    | 2 if true
	nop
	; Stop bit
	; Stop bit is 2 us low, then leave the line high
	sbi N64_DDR, N64_DATA
	rcall wait_1us_8mhz   ; | 8
	rjmp pc+1
	rjmp pc+1
	rjmp pc+1
	cbi N64_DDR, N64_DATA ; | 2

	ldi r16, (1<<INT0) ; Clear INT0 in EIFR, which could be set while we
	out EIFR, r16      ; were sending data

	sei
	ret

 ; Set up interrupt handler
 n64_init:
     cli
	 ; Set up ports
     cbi N64_DDR, N64_DATA
     cbi N64_PORT, N64_DATA

	 in r16, MCUCR
	 ori r16, (1<<ISC01) | (0<<ISC00) ; Interrupt on falling edge
	 out MCUCR, r16

	 in r16, GIMSK
	 ori r16, (1<<INT0) ; Enable INT0
	 out GIMSK, r16
	 sei
	 ret

n64_ident: .db 0x05, 0x00, 0x02, 0x00
