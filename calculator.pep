; Main routine
main:    CALL    getInp
         CALL    detOp
         
         STRO    eqSign,d
         DECO    result,d

         LDBA    '\n',i
         STBA    charOut,d
         BR      main

         STOP

; Get input: numbers and operation
getInp:  DECI    num1,d         
         LDBA    charIn,d
         STBA    oper,d
         DECI    num2,d
         RET

; Determine operation subroutine
detOp:   LDBA    oper,d      ; Go to Add
         SUBA    43,i
         BREQ    add

         LDBA    oper,d      ; Go to Sub
         SUBA    45,i
         BREQ    sub

         ; Else
         STRO    errorOp,d   ; Invalid Operation message
         BR      main
         RET

; Addition subroutine (DEC 43)
add:     LDWA    num1,d
         ADDA    num2,d
         STWA    result,d
         RET

; Subtraction subroutine (DEC 45)
sub:     LDWA    num1,d
         SUBA    num2,d
         STWA    result,d
         RET 

num1:    .WORD   0    
num2:    .WORD   0
result:  .WORD   0

eqSign:  .ASCII  "="

oper:    .ASCII  "\x00"
errorOp: .ASCII  "Error: Invalid Operation\n\x00"

.end