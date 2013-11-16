;*
;* gc.inc
;*
;*  Created: 11/1/2013 1:50:18 AM
;*   Author: Michael Beeuwsaert
;* 

 .equ GC_DDR   = DDRD
 .equ GC_PIN   = PIND
 .equ GC_PORT  = PORTD
 .equ GC_DATA  = PD3

 ; References: http://www.int03.co.uk/crema/hardware/gamecube/gc-control.htm
;           : https://github.com/brownan/Gamecube-N64-Controller
; Assumes 8Mhz clock

; GC protocol
; High bit:
;            ___
;  _________/
; ^   3us   ^1us^
;
; Low bit:
;      _________
;  ___/
; ^1us^   3us   ^
; Each byte is 8 bits. There is also a single high stop bit at the end of a stream of bits.

    ; Z - pointer to data to send
    ; r18 - Number of bytes to send
    ; clobbers r16, r20
gc_send_8mhz:
    ; Assumes 8mhz clock
    cli

    ; Instead of counting down the bits, we count up by 32, but still use
    ; the Z flag for branching--this saves a clock cycle in the
    ; byte-send loop.
    ldi r20, 32
    mov r0, r20
    ldi r20, 0
    gc_send_bytes_loop_8mhz:
        lpm r16, Z+   ;                  | 3
        gc_send_bits_loop_8mhz:
            sbi GC_DDR, GC_DATA ;      | 2
            lsl r16   ; Shift msb into C | 1
            brcc gc_send_bit_low_8mhz ; | 1 if false
                                       ; | 2 if true
            ; Send high bit
            ; timing: 1 us low, 3 us high
            ; we're at 2/8 clocks needed for low
            rjmp pc+1
            rjmp pc+1
            cbi GC_DDR, GC_DATA ;     | 2
            rcall wait_1us_8mhz   ;     | 8
            rjmp pc+1
            rjmp pc+1
            nop
            ;rjmp pc+1             ;       | 6
            rjmp gc_send_bit_cont_8mhz ; | 2
                                        ; 8 clocks left over
        gc_send_bit_low_8mhz:
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
            cbi GC_DDR, GC_DATA ;    | 2
                                  ; 8 clocks left over
        gc_send_bit_cont_8mhz: ; 6 clocks left to use (after loading the next bit, and branching)
                                ; 5 clocks left to use if we need to load the next byte
        add r20, r0               ;    | 1
        ;dec r20                   ;    | 1
        breq gc_send_next_byte   ;    | 1 if false
                                  ;    | 2 if true
        rjmp pc+1
        rjmp gc_send_bits_loop_8mhz ; | 2
    gc_send_next_byte:
    dec r18                       ;    | 1
    brne gc_send_bytes_loop_8mhz ;    | 1 if false
                                  ;    | 2 if true
    nop
    ; Stop bit
    ; Stop bit is 1 us low, then leave the line high
    sbi GC_DDR, GC_DATA
    rjmp pc+1
    rjmp pc+1
    rjmp pc+1
    cbi GC_DDR, GC_DATA ; | 2

    sei
    ret

; Y - Pointer to buffer that will receive the data
; r17 - Number of bytes to read
gc_read:
    cli
	in r21, SREG
    ; Add 32 to r18, to try and save a cycle
    ldi r18, 32
    mov r0, r18
    ldi r18, 0
    gc_read_byte:
        gc_read_bit:
        
        ; Wait for line to go low, with timeout, in case things go horribly wrong
        ldi r20, 0x3f
        gc_read_wait_low:
                dec r20
                breq gc_read_timeout
                sbic GC_PIN, GC_DATA
                rjmp gc_read_wait_low
            ;nop
            ; wait for line to steady out
            rcall wait_1us_8mhz
            ; Read and save the bit
            in r1, GC_PIN
            bst r1, GC_DATA
            lsl r25
            bld r25, 0
            ldi r20, 0x3f

            ; Check for end of byte, and skip waiting for line to go high if so
            ; otherwise it takes too long, and messes up the timing.
            add r18, r0
            breq gc_read_save_byte

            ; Wait for line to go high (try to stay in sync)
            gc_read_wait_high:
                dec r20
                breq gc_read_timeout
                sbis GC_PIN, GC_DATA
                rjmp gc_read_wait_high
            
            rjmp gc_read_bit
        gc_read_save_byte:
        ; Save the byte we just read
        st Y+, r25
    dec r17
    brne gc_read_byte

    gc_read_timeout:
	out SREG, r21
    sei
    ret

gc_init:
    ; Set up ports
    cbi GC_DDR, GC_DATA
    cbi GC_PORT, GC_DATA
    ;ldi r16, 0
    ;out GC_DDR, r16
    ;ldi r16, 0
    ;out GC_PORT, r16

    ; Init gamecube controller
    ldi ZL, LOW( 2 * gc_init_cmd )
    ldi ZH, HIGH( 2 * gc_init_cmd )
    rcall gc_send_8mhz

    ; Wait for the controller to idle
    gc_init_idle_loop:
        sbis GC_PIN, GC_DATA
        ldi r16, 64
        dec r16
        brne gc_init_idle_loop
    ret

gc_init_cmd: .db 0xaa, 0xaa, 0xaa, 0
gc_poll_cmd: .db 0x40, 0x03, 0x00, 0
