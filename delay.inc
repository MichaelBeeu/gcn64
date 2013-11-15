/*
 * delay.inc
 *
 *  Created: 11/1/2013 12:15:38 PM
 *   Author: Owner
 */ 

; Assumes 8mhz clock
 wait_1us_8mhz:  ; RCALL takes 2 cycles
    rjmp pc+1    ; 2 cycles
    ret       ; 4 cycles

wait_6cycles: ; RCALL - 2 cycles
    ret       ; 4 cycles