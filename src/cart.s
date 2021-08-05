; From Andreas, for cart:
; i let $fffe/ffff point to irqHandler and I let $0314/15 point to kernel: then timing is equal
;
;      pha               ; 3
;      txa               ; 2
;      pha               ; 3
;      tya               ; 2
;      pha               ; 3
;      tsx               ; 2
;      lda $0104,x       ; 4
;      and #$10          ; 2
;      beq :+            ; 3
;      nop               ;
;   :                 ;
;      jmp ($0314)       ; 5     jmp (ind)         ; that's a comment... i point 0314/15 to there, the comment is to remind me of that pointer
;                        ;
;   * = ($0314)       ;
;      kernel:
;      dec $d019
;      pla
;      tay
;      pla
;      tax
;      pla
;      rti
;             
; that code “simulates” what the kernel does
; so with kernel swapped out everything is executed by your own code, swapped in the kernel does its’ thing and jumps to “kernel:”
