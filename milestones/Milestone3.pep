; Created by Larry Tseng 2018.

; Main routine (calls input and operation determiner subroutines, prints a newline, loops)
main:    CALL    getInp
         CALL    detOp

         LDBA    '\n',i      ; Newline
         STBA    charOut,d

         LDWA    0,i         ; Reset result
         STWA    result,d

         BR      main        ; Loop

         STOP

; Get user input subroutine: numbers and operation, detect individual overflow
getInp:  DECI    num1,d      ; Max is 32767 (32768 overflows)
         BRV     prOver      ; Branch if Overflow

         LDBA    charIn,d
         STBA    oper,d

         DECI    num2,d
         BRV     prOver      ; Branch if Overflow

         RET

; Determine operation subroutine (subtracts the DEC value from the ASCII input to check for each operation)
detOp:   LDWA    0,i         ; Reset accumulator
         LDBA    oper,d      ; Go to Add
         SUBA    42,i        ; (DEC 42 from ASCII Table)
         BREQ    mult

         LDWA    0,i         ; Reset accumulator
         LDBA    oper,d      ; Go to Add
         SUBA    43,i        ; (DEC 43 from ASCII Table)
         BREQ    add
         
         LDWA    0,i         ; Reset accumulator
         LDBA    oper,d      ; Go to Sub
         SUBA    45,i        ; (DEC 45 from ASCII Table)
         BREQ    sub

         STRO    errorOp,d   ; Invalid Operation message
         LDWA    0,i         ; Reset accumulator
         RET

; Multiplication subroutine (Loops, multiplies two numbers together)
mult:    LDWA    num2,d      ; num1 = ToBeMultiplied, num2 = Multiplier
         BREQ    outAnsw     ; Once loop is finished, print answer
         BRLT    multInv

         SUBA    1,i         ; subtract one from loop
         STWA    num2,d      
         
         LDWA    result,d    ; Add num1 to result
         ADDA    num1,d
         BRV     prOver      ; If overflow, print message
         STWA    result,d

         BR      mult
         RET 

; Multiplication negative inverter
multInv: LDWA    0,i
         SUBA    num2,d      ; If num2 is negative, invert num2 and num1
         STWA    num2,d

         LDWA    0,i
         SUBA    num1,d
         STWA    num1,d
         BR      mult

; Addition subroutine  (Adds the second number to the first)
add:     LDWA    num1,d
         ADDA    num2,d
         BRV     prOver
         STWA    result,d
         CALL    outAnsw
         RET

; Subtraction subroutine (Subtracts the second number from the first)
sub:     LDWA    num1,d
         SUBA    num2,d
         BRV     prOver
         STWA    result,d
         CALL    outAnsw
         RET 

; Outputs the answer (Prints out an = sign and the answer)
outAnsw: STRO    eqSign,d
         DECO    result,d
         RET

; Overflow error message
prOver:  STRO    overMsg,d
         BR      main

; Data
num1:    .WORD   0    
num2:    .WORD   0
result:  .WORD   0

eqSign:  .ASCII  "=\x00"

oper:    .ASCII  "\x00"
errorOp: .ASCII  "Error: Invalid Operation\n\x00"

overMsg: .ASCII  "Error: Overflow\n\x00"

.end