TITLE Selection Sort (sel.asm)

;*******************************************************************************
;Programmer 	Blake Kellar
;Date		11.16.2004
;Description	Generates random array, displays it, sorts it, displays it

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

.data
dArray		DWORD	50 DUP(0)

.code
main PROC

invoke genarray,  offset darray, lengthof darray	;Generate array
invoke disparray, offset darray, lengthof darray	;Display generated array
INVOKE selsort,   OFFSET darray, LENGTHOF darray	;sort
invoke disparray, offset darray, lengthof darray	;Display sorted array

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
mov smallest,ARRAY_SIZE

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
