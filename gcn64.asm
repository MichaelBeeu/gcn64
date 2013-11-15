/*
 * gcn64.asm
 *
 *  Created: 11/1/2013 1:47:56 AM
 *   Author: Owner
 */ 

.include "tn2313def.inc"

.cseg
.org 0000

rjmp main    ; Reset
rjmp n64_int ; INT0

.org INT_VECTORS_SIZE

;.include "debug.inc"
.include "delay.inc"
.include "gc.inc"
.include "n64.inc"

; Y: Pointer to GameCube data
; Z: Pointer to N64 output
gcToN64:
    ; Gamecube controller format:
	;      Bit __7__ __6__ __5__ __4__ __3__ __2__ __1__ __0__
	; Byte 0: |  0  |  0  |  ?  |  S  |  Y  |  X  |  B  |  A  |
	; Byte 1: |  1  |  L  |  R  |  Z  | Dup | Ddn | Drt | Dlf |
	; Byte 2: | Joystick X                                    |
	; Byte 3: | Joystick Y                                    |
	; Byte 4: | C Stick X                                     |
	; Byte 5: | C Stick Y                                     |
	; Byte 6: | Left trigger value                            |
	; Byte 7: | Right trigger value                           |  

	; N64 format:
    ;      Bit __7__ __6__ __5__ __4__ __3__ __2__ __1__ __0__
	; Byte 0: |  A  |  B  |  Z  |  S  | Dup | Ddn | Dlf | Drt |
	; Byte 1: |  0  |  0  |  L  |  R  | Cup | Cdn | Clf | Crt |
	; Byte 2: | Joystick X                                    |
	; Byte 3: | Joystick Y                                    |
	; Joystick range is -128 to 127, but physically limited to -81 to 81

	; Save SREG, because we use the T flag a lot here
	; and also to signal when there's n64 data available
	cli

	in r16, SREG
	push r16

	eor r17, r17
	ld r16, Y+   ; Load first byte from game cube

	bst r16, 0   ; A
	bld r17, 7

	bst r16, 1   ; B
	bld r17, 6

	bst r16, 4   ; Start
	bld r17, 4

	ld r16, Y+

	bst r16, 4   ; Z
	bld r17, 5

	bst r16, 3   ; D-up
	bld r17, 3

	bst r16, 2   ; D-down
	bld r17, 2

	bst r16, 1   ; D-right
	bld r17, 0

	bst r16, 0   ; D-left
	bld r17, 1

	st Z, r17   ; Store first n64 byte

	eor r17, r17

	bst r16, 6   ; L
	bld r17, 5

	bst r16, 5   ; R
	bld r17, 4

	; C-buttons
	; TODO: Actually implement the C buttons
/*	set
	ldd r16, Y+3      ; C-stick Y axis (up/down c-button)
	lsr r16
	subi r16, 64
	sbrs r16, 7       ; C-up
	bld r17, 3
	sbrc r16, 7       ; C-down
	bld r17, 2

	ldd r16, Y+2      ; C-stick X axis (left/right c-button)
	lsr r16
	subi r16, 64
	sbrs r16, 7       ; C-right
	bld r17, 1
	sbrc r16, 7       ; C-left
	bld r17, 0
	*/

	std Z+1, r17       ; Second n64 byte

	ld r16, Y+ ; Joystick X
	; TODO: fix axis limit; Right now it's -64 to 63
	; Can it be -128 to 127 without causing games to act erratic?
	
	lsr r16
	subi r16, 64
	;subi r16, 128
	;asr r16
	;asr r16
	;subi r16, 31
	;andi r16, 0b10011111
	std Z+2, r16

	ld r16, Y+ ; Joystick Y
	; TODO: fix axis limit; Right now it's -64 to 63
	
	lsr r16
	subi r16, 64
	;clc
	;subi r16, 128
	;asr r16
	;asr r16
	;subi r16, 31
	;andi r16, 0b10011111
	std Z+3, r16

	pop r16
	out SREG, r16

	sei
	ret

main:
    ; Force 8mhz
	ldi r16, (1<<CLKPCE)
	sts CLKPR, r16
	ldi r16, (1<<CLKPS0)
	sts CLKPR, r16

	; Set up stack
	;ldi r16, HIGH(RAMEND)
	;out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	; Init GC controller
	rcall gc_init
	; Init n64
	rcall n64_init

    ; Send initialization command to GC controller
	ldi ZL, LOW( 2 * gc_init_cmd )
	ldi ZH, HIGH( 2 * gc_init_cmd )
	ldi r18, 3
	rcall gc_send_8mhz

	; Move n64 ident data into sram
	ldi ZL, LOW( 2 * n64_ident )
	ldi ZH, HIGH( 2 * n64_ident )
	ldi XL, LOW( n64_ident_buf )
	ldi XH, HIGH( n64_ident_buf )
	ldi r18, 4
	n64_load_ident:
	    lpm r16, Z+
		st X+, r16
	    dec r18
		brne n64_load_ident

	main_loop:
	    sei
		; Wait until interrupt handler has just finished responding to a request
		; before polling gamecube controller, because polling the controller
		; cannot be interrupted, and if we miss responding to the N64, some games
		; act strange.
		brtc main_loop
		clt

		ldi YL, LOW( gc_buf )
		ldi YH, HIGH( gc_buf )

		ldi ZL, LOW( 2 * gc_poll_cmd )
		ldi ZH, HIGH( 2 * gc_poll_cmd )

		; Poll gamecube controller
		ldi r18, 3
		rcall gc_send_8mhz

		ldi r17, 8
		rcall gc_read

		; Convert to n64 data
		ldi YL, LOW( gc_buf )
		ldi YH, HIGH( gc_buf )

		ldi ZH, HIGH( n64_buf )
		ldi ZL, LOW ( n64_buf )

		rcall gcToN64
	
	rjmp main_loop

.dseg
gc_buf : .byte 8
n64_buf: .byte 4
n64_ident_buf: .byte 4