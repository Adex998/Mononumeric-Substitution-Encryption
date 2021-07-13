
#make_bin#

; BIN is plain binary format similar to .com format, but not limited to 1 segment;
; All values between # are directives, these values are saved into a separate .binf file.
; Before loading .bin file emulator reads .binf file with the same file name.

; All directives are optional, if you don't need them, delete them.

; set loading address, .bin file will be loaded to this address:
#LOAD_SEGMENT=0500h#
#LOAD_OFFSET=0000h#

; set entry point:
#CS=0500h#	; same as loading segment
#IP=0000h#	; same as loading offset

; set segment registers
#DS=0500h#	; same as loading segment
#ES=0500h#	; same as loading segment

; set stack
#SS=0500h#	; same as loading segment
#SP=FFFEh#	; set to top of loading segment

; set general registers (optional)
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#


;Store Number Table 1 to 26
MOV CX, 26 ;26 number for all letter
MOV AL,1 ;1 starting table of numbers
MOV DI,360H ;why 60?
;ex:'a'is i/p =61ascii so i can use a-1 as offcet to get to number table

Store_table_number:
STOSB ; Store AL at address ES:(E)DI
INC AL ;  
LOOP Store_table_number;

; Store LETTER For Decrept
;why another table? to use xlatb with offcet easier
MOV CX, 26 ;26 letter
MOV AL,61H ;a Letter with ASCII
MOV DI,394H ;

STORE_LETTER_LOOP2:
STOSB ; Store AL at address ES:(E)DI
INC AL ;  
LOOP STORE_LETTER_LOOP2;


Start_App:

LEA DX, dec_enc_ask
MOV AH, 9 
INT 21h


;take the massage
LEA DX, buffer
MOV AH, 0Ah ; Sub-function that stores input of a string to DS:DX
INT 21h

; Puts $ at the end
MOV BX,0
MOV BL, buffer[1]
MOV buffer[BX + 2], '$'
LEA SI, buffer[2]

CMP [SI], '$' ; Check if reached end of message
	JE end_app
LODSB
CMP AL, '1'
jE Encrypt
CMP AL, '2'
jE Decrypt
jne end_app 

Encrypt:
;print msg
LEA DX, ask_enc
MOV AH, 9 
INT 21h

;take the massage
LEA DX, buffer2
MOV AH, 0Ah ; Sub-function that stores input of a string to DS:DX
INT 21h


; Puts $ at the end
MOV BX,0
MOV BL, buffer2[1]
MOV buffer2[BX + 2], '$'

;print "The encrypted message is:"
LEA DX, encryptout_msg
MOV AH, 9 
INT 21h


;Encrypt code
MOV DI, 35Fh
MOV BX, DI
LEA SI, buffer2[2]


next_byte:
	CMP [SI], '$' ; Check if reached end of message
	JE end_app
	
	LODSB ; Loads first char into AL, then  moves SI to next char
	CMP AL,20H
	JE print_space 
	CMP AL, 'a'
	JB  next_byte ; If char is invalid, skip it
	CMP AL, 'z'
	JA  next_byte  
	SUB AL,60H    
	
	XLATB     ; Encrypt    
	
	mov ah, 0
	mov cl, 10
	div cl
	mov DX, AX
	
	
    ;print msg
    LEA DL, DL
    MOV AH, 2
    add dl,30h 
    INT 21h
    
    LEA DL, DH
    MOV AH, 2
    add dl,30h 
    INT 21h
 
 JMP next_byte
jmp end_app 
 
  
Decrypt: 
;print msg
LEA DX, ask_dec
MOV AH, 9 
INT 21h 

;take the massage
LEA DX, buffer3
MOV AH, 0Ah ; Sub-function that stores input of a string to DS:DX
INT 21h

; Puts $ at the end
MOV BX,0
MOV BL, buffer3[1]
MOV buffer3[BX + 2], '$'

;print "The decrypted message is:"
LEA DX, decryptout_msg
MOV AH, 9 
INT 21h

;Decrypt code
MOV DI, 393h
MOV BX, DI
LEA SI, buffer3[2]

next_letter:
CMP [SI], '$' ; Check if reached end of message
JE end_app
LODSW   
CMP AL,20H
JE print_space2
CMP AL, '0'
JB  next_letter ; If char is invalid, skip it
CMP AL, '9'
JA  next_letter

;turn ascii to hex
mov DL,Ah
Mov Dh,Al
sub DL,30H
SUB DH,30H
MOV AX,10
MUL DH
MOV DH,AL
ADD DL,DH
MOV AL,DL  

XLATB

;print msg
    LEA DL, AL
    MOV AH, 2 
    INT 21h

JMP next_letter


end_app:



JMP start_App  

print_space:

    MOV DX, 20H
    LEA DX, DX
    MOV AH, 2
    INT 21h 
    JMP next_byte
print_space2:
    MOV DX, 20H
    LEA DX, DX
    MOV AH, 2
    INT 21h  
    SUB SI,1H
    JMP next_letter

HLT           ; stop!


dec_enc_ask db 0Dh,0Ah,0Dh,0Ah, "Do u Want 1:Encrypt 2:Decrypt $" 
buffer db 3,?  
buffer2 db 27,?, 27 dup(' ') 
buffer3 db 27,?, 27 dup(' ')
ask_enc db 0Dh,0Ah, "Enter a message to Encrypt: $"  
ask_dec db 0Dh,0Ah, "Enter a message to Decrypt IN TWO DIGIT: $"  
encryptout_msg db 0Dh,0Ah, "The encrypted message is: $" 
decryptout_msg db 0Dh,0Ah, "The Decrypted message is: $"   




