TITLE binary search

;*******************************************************************************
;Programmer 	Blake Kellar
;Date		11.16.2004
;Description	Generates random array, displays it, sorts it, displays it
;		attempts to binary search it

INCLUDE Irvine32.inc

;PROTOTYPE
selsort 	PROTO,	off:PTR DWORD,	len:DWORD
genarray 	PROTO,	off:PTR DWORD,	len:DWORD
disparray 	PROTO,	off:PTR DWORD,	len:DWORD

findsmall PROTO,
numbers:PTR DWORD,		;Take addressof array
array_size:DWORD,		;Take num bytes in array
leftptr:DWORD;,			;subscript of starting elem to search
				;(so we dont search the sorted portion)

swap PROTO,
off1:PTR DWORD,		;take two addresses to swap the elements of
off2:PTR DWORD

BINSRCH PROTO,
NUMBERS:PTR DWORD,		;TAKE OFFSET OF ARRAY
ARRAY_LENGTH:DWORD,		;TAKE ARRAY LENGTH (NUM ELEMENTS)
ITEM:DWORD			;TAKE ITEM TO FIND

.data
dArray	DWORD	50 DUP(0)
PROMPT1 BYTE 	"ENTER NUMBER TO FIND: ",0
yep byte "Found at position ",0
nope byte "not found.",0

.code
main PROC

invoke genarray,  offset darray, lengthof darray	;Generate array
invoke disparray, offset darray, lengthof darray	;Display generated array
INVOKE selsort,   OFFSET darray, LENGTHOF darray	;sort
invoke disparray, offset darray, lengthof darray	;Display sorted array

mov edx,offset prompt1
call writestring
call readint

invoke binsrch, offset darray,lengthof darray, eax

.IF EAX == 0
mov edx,offset nope
call writestring
.ELSE
mov edx,offset yep
call writestring
mov eax,ebx
call writeint
.ENDIF

exit
main ENDP

;------------------------------------------------------------------------------
genarray PROC,
off:PTR DWORD,
len:DWORD
;
;	Array is filled with random DWORD elements
;------------------------------------------------------------------------------
mov ecx,len
mov esi,off
MakeNext:
mov EAX,10 ;4294967295	;Random between 0 and (Max DWORD val)
call randomrange
mov [esi],eax		;Put random number into array
add esi,4		;Point to next element in array
loop MakeNext		;Run [ECX] times
ret
genarray ENDP

;------------------------------------------------------------------------------
disparray PROC,
off:PTR DWORD,
len:DWORD
;
;POST	Array is output to screen
;------------------------------------------------------------------------------
mov esi,off
mov ecx,len
DispNext:
mov eax,[esi]
call writedec		;Write array element to screen
call crlf		;Next Line
add esi,4		;Point to next element in array
loop DispNext		;Run [ECX] times
call crlf
ret
disparray ENDP

;--------------------------------------------------------------------------****
selsort PROC,
numbers:PTR DWORD,		;Take addressof array
array_size:DWORD		;Take num bytes in array
; 
;POST	Array is sorted
;------------------------------------------------------------------------------
LOCAL I:DWORD,TEMP1:PTR DWORD,TEMP2:PTR DWORD

mov I,0
mov esi,numbers

TopSort:
mov edx,array_size
SHL EDX,2		;EDX = NUM BYTES TO RUN
cmp I,edx		;run until i >= arraysize
jae donesort

MOV EDX,I
SHR EDX,2

invoke findsmall, offset darray, lengthof darray, EDX	;find smallest TO EAX
SHL EAX,2

MOV TEMP1,ESI
MOV EDX,I
ADD TEMP1,EDX
MOV TEMP2,ESI
ADD TEMP2,EAX

invoke swap,TEMP1,TEMP2			;swap i with smallest in array

ADD I,4
jmp topsort

donesort:

ret
selsort ENDP

;------------------------------------------------------------------------------
swap PROC,
off1:PTR DWORD,		;take two addresses to swap the elements of
off2:PTR DWORD
;------------------------------------------------------------------------------
LOCAL temp:DWORD

PUSHAD

mov esi,off1
mov edi,off2

mov edx,[esi]
mov temp,edx

mov edx,[edi]
mov [esi],edx

mov edx,temp
mov [edi],edx

POPAD

ret
swap ENDP

;------------------------------------------------------------------------------
findsmall PROC,
numbers:PTR DWORD,		;Take addressof array
array_size:DWORD,		;Take num bytes in array
leftptr:DWORD,			;subscript of starting elem to search
				;(so we dont search the sorted portion)
;returns smallest elem position to eax.
;------------------------------------------------------------------------------

LOCAL smallest:DWORD	;points into array at smallest elem
MOV EDX,ARRAY_SIZE
mov smallest,EDX

mov esi,numbers		;offset
mov eax,leftptr		;left pointer
mov ebx,leftptr		;right pointer (left+1elem)
add ebx,1

Top:			;debug: this runs fine
mov edx,array_size
cmp ebx,edx
jae donescanning	;run until right pointer is at last element

mov edx,[esi+ebx*4]
mov ecx,smallest
shl ecx,2

cmp [esi+ecx],edx	;if left elem > smallest elem, new smallest is right

jb notnewsmall
mov smallest,ebx

notnewsmall:
add eax,1
add ebx,1		;increment left and right pointers (to elem)	
jmp TOP

donescanning:
mov eax,smallest

ret
findsmall ENDP

;------------------------------------------------------------------------------
BINSRCH PROC,
NUMBERS:PTR DWORD,		;TAKE OFFSET OF ARRAY
ARRAY_LENGTH:DWORD,		;TAKE ARRAY LENGTH (NUM ELEMENTS)
ITEM:DWORD			;TAKE ITEM TO FIND

; RETURNS TRUE/FALSE TO EAX (WAS ARRAY ELEM FOUND?)
; RETURNS POSITION OF ITEM TO EBX (ONLY VALID IF EAX IS TRUE)
; USES EDX THROUGHOUT FOR TEMP !MEM->MEM
;------------------------------------------------------------------------------
LOCAL FOUND:DWORD,FIRST:DWORD,LAST:DWORD,MID:DWORD

pushad

MOV ESI,NUMBERS		;ESI POINTS TO ARRAY
MOV EDX,ARRAY_LENGTH
SHL EDX,2
MOV ARRAY_LENGTH,EDX	;ARRAY LENGTH IS NOW NUMBER OF BYTES

MOV FOUND,0		;FOUND=FALSE
MOV FIRST,0		;FIRST=0TH ELEMENT
MOV EDX,ARRAY_LENGTH
MOV LAST,EDX
SUB LAST,4		;LAST = N - 1ELEM

BINWHILE:
MOV EDX,LAST
CMP FIRST,EDX
JGE DONEBIN
CMP FOUND,0
JNE DONEBIN		;WHILE FIRST<LAST _AND_ WHILE FOUND != 1

MOV EDX,FIRST
MOV MID,EDX
MOV EDX,LAST
ADD MID,EDX
SHR MID,1		;MID = (FIRST+LAST)/2

MOV EBX,[ESI+MID]

.IF ITEM < EBX
	MOV EDX,MID
	SUB EDX,4
	MOV LAST,EDX
.ELSEIF ITEM > EBX
	MOV EDX,MID
	ADD EDX,4
	MOV FIRST,EDX
.ELSE
	MOV FOUND,1
.ENDIF

JMP BINWHILE
DONEBIN:

popad

MOV EAX,FOUND
MOV EBX,MID

ret
BINSRCH ENDP

END main ;EOF

;void selectionSort(int numbers[], int array_size)
;{
;  int i, j;
;  int min, temp
;  for (i = 0; i < array_size-1; i++)
;  {
;    min = i;
;    for (j = i+1; j < array_size; j++)
;    {
;      if (numbers[j] < numbers[min])
;        min = j;
;    }
;    temp = numbers[i];
;    numbers[i] = numbers[min];
;    numbers[min] = temp;
;  }
;}

;I=0
;WHILE I < ARRAYSIZE - 1ELEM
	;MIN=I
	;FIND ADDR OF SMALLEST(MIN) TO ESI	;needs n,i,min
	;SWAP N[I] WITH N[ESI]			;needs n,i,min
;