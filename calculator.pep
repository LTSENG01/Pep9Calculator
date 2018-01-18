; Created by Larry Tseng 2018.
  
         STRO    introMsg,d  ; Display intro message

; Main routine (calls input and operation determiner subroutines, prints a newline, loops)
main:    CALL    getInp
         CALL    detOp

reset:   LDBA    '\n',i      ; Newline
         STBA    charOut,d

         LDWA    0,i         ; Reset result
         STWA    result,d
         STWA    num1,d      ; reset num1
         STWA    num2,d      ; reset num2

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
         LDBA    oper,d      ; Go to Multiply
         SUBA    42,i        ; (DEC 42 from ASCII Table)
         BREQ    mult

         LDWA    0,i         ; Reset accumulator
         LDBA    oper,d      ; Go to Divide
         SUBA    47,i        ; (DEC 47 from ASCII Table)
         BREQ    divPre

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
multInv: LDWA    num2,d
         NEGA                ; If num2 is negative, invert num2 and num1
         STWA    num2,d

         LDWA    num1,d
         NEGA    
         STWA    num1,d
         BR      mult

; Check if answer is zero
divPre:  LDWA    num1,d
         BREQ    answZero

         BRLT    divInv1

         LDWA    num2,d
         BRLT    divInv2

         LDWA    num1,d
         SUBA    num2,d

         BRLT    answZero 

; Division subroutine (Loops, subtracts second num from first num, increments result)  
divide:  LDWA    num2,d 
         BREQ    prErrZer     
         BRLT    divInv2

         LDWA    num1,d      ; Load the starting number
         BRLT    divInv1

         LDWA    num1,d
         SUBA    num2,d      ; Subtract the divisor
         STWA    num1,d      ; Store the result as starting number
         LDWA    result,d    ; Load the previous dividend
         ADDA    1,i         ; Add one
         STWA    result,d    ; Store the current dividend
         
         ; check
         LDWA    num1,d      ; Check routine, load starting number
         SUBA    num2,d      ; Subtract divisor
         BRLT    outAnsw     ; If divisor < starting number, then it is done
         BR      divide      ; Else loop back to divide

; Negate the 1st number
divInv1: NEGA                ; If num1 is negative, negate it
         STWA    num1,d
         LDWA    num1Neg,d   ; Set num1Neg flag to 1
         ADDA    1,i         
         STWA    num1Neg,d
         BR      divPre

; Negate the 2nd number
divInv2: NEGA                ; If num2 is negative, negate it
         STWA    num2,d
         LDWA    num2Neg,d   ; Set num2Neg flag to 1
         ADDA    1,i
         STWA    num2Neg,d
         BR      divPre

; Checks if any numbers are negative
checkNeg:LDWA    num1Neg,d
         ANDA    num2Neg,d   ; 1 if both flags are set (answer is +), else 0
         BRGT    resetNeg
         
         LDWA    num1Neg,d
         ORA     num2Neg,d   ; 1 if either are negative
         BRGT    printNeg
         BR      outAns2

; If answer is automatically zero, print it out
answZero:LDWA    0,i
         STWA    result,d
         BR      outAnsw

; if negative, prints a - symbol
printNeg:LDBA    '-',i
         STBA    charOut,d

         CALL    resetNeg
               
         BR      checkNeg

; resets the division negative flags
resetNeg:LDWA    0,i
         STWA    isNeg,d     ; reset isNeg to 0
         STWA    num1Neg,d
         STWA    num2Neg,d
         BR      checkNeg

; Prints error message when dividing by zero
prErrZer:STRO    divZero,d
         RET

; negativeVariableFlags
num1Neg: .WORD   0
num2Neg: .WORD   0
isNeg:   .WORD   0
         
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
         CALL    outAns2
         RET

outAns2: BRNE    checkNeg
         DECO    result,d
         BR      reset

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

divZero: .ASCII  "Error: Division by zero\n\x00"

introMsg: .ASCII "+---------------+\n| Calculator v1 |\n| by Larry T    |\n+---------------+\n\n\x00" 

.end
