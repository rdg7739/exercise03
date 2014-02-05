	;; file: encode.asm
	;;
	;;

%define STDIN 0
%define STDOUT 1
%define SYSCALL_EXIT 1
%define SYSCALL_READ 3
%define SYSCALL_WRITE 4
%define BUFLEN 256
%define TITLE_OFFSET 0 
%define AUTHOR_OFFSET 48 
%define SUBJECT_OFFSET 96 
%define YEAR_OFFSET 116 
%define NEXT_OFFSET 120

	SECTION .data

lf:	 db 10			;line feed
space:	 db 32			;space 
comma:	db 44			;comma
	SECTION .bss		;uninitialized data section

input:	resb BUFLEN		;buf for input
iLen:	resb 4			;length of input
stringLen:	 resb 1
string:	resb 4

	SECTION .text		;code section.
	global _start		;let loader see entry point
	extern library
	;; 	extern prt_dec		
	
_start:	 nop			;entry point
start:				;address for gdb
	mov esi, [library]	;copy library data to esi

hasBook:
	mov eax, 0		;zero out eax
	mov ecx, 0		;zero out ecx // initalize book 
	cmp esi, 00h		;if no more book( esi == null)
	je exit 
	
checkSubject:
	mov al, [esi + ecx + SUBJECT_OFFSET] ;check if subject is equal or not
	cmp al, 'F'
	jne nextBook		;jmp to next book if subject is not 'Fantasy'
	inc ecx			;do same thing all to 'y'

	mov al, [esi + ecx + SUBJECT_OFFSET]
	cmp al, 'a'
	jne nextBook
	inc ecx

	mov al, [esi + ecx + SUBJECT_OFFSET]
	cmp al, 'n'
	jne nextBook
	inc ecx

	mov al, [esi + ecx + SUBJECT_OFFSET]
	cmp al, 't'
	jne nextBook
	inc ecx

	mov al, [esi + ecx + SUBJECT_OFFSET]
	cmp al, 'a'
	jne nextBook
	inc ecx

	mov al, [esi + ecx + SUBJECT_OFFSET]
	cmp eax, 's'
	jne nextBook
	inc ecx

	mov al, [esi + ecx + SUBJECT_OFFSET]
	cmp eax, 'y'
	jne nextBook
	inc ecx

	mov al, [esi + ecx + SUBJECT_OFFSET] 
	cmp eax, 00h		;jmp to next book if subject is not exactly 'Fantasy'
	jne nextBook
	je len_init	;print book's info only if subject is 'Fantasy'

nextBook:
	mov esi, [esi + NEXT_OFFSET] ;set esi address to next book
	jmp hasBook		     ;check that book is exist or not 

len_init:
	mov ecx, 0		;initalize print 
lenT:
	mov al, [esi + ecx + TITLE_OFFSET]
	inc ecx			;count for title length
	cmp al, 00h		;check if the title has reached end
	jne lenT		;jmp while title string's char exist
	
prt_T:
	lea edi, [esi + TITLE_OFFSET]
	call prt_string
		
lenA:
	mov eax, 0
	mov al, [esi + ecx + AUTHOR_OFFSET]
	inc ecx			;count for author length
	cmp al, 00h		;check if the author has reached end
	jne lenA		;jmp  while author's char is left

prt_A:	
	lea edi, [esi + AUTHOR_OFFSET]	;set edi  to author position
	call prt_string

lenS:
	mov eax, 0
	mov al, [esi + ecx + SUBJECT_OFFSET]
	inc ecx			;track the length of ecx
	cmp al, 00h		;check that subject has reached end
	jne lenS		;jmp while subject's char is left
	
prt_S:
	lea edi,  [esi + SUBJECT_OFFSET]	;go esi to subject position
	call prt_string
	
printY:
	mov eax, [esi + YEAR_OFFSET]
	;; 	call	prt_dec		;print year of book by using 'prt_dec'
	call prt_lf
	je nextBook

exit:	mov	eax, SYSCALL_EXIT ; exit if no books left in the library
	mov	ebx, 0
	int	080h
	
	
prt_lf:				;print line feed 
    mov     eax, SYSCALL_WRITE      ; write message
    mov     ebx, STDOUT
    mov     ecx, lf
    mov     edx, 1			; LF is a single character
    int     080h
	ret

prt_string:
	mov [stringLen], ecx	;move subject's length to stringLen
	mov eax, SYSCALL_WRITE
	mov ebx, STDOUT
	mov ecx, edi
	mov edx, [stringLen]
	int 080h

	call prt_comma		;print comma and space
	mov ecx, 0
	
	ret
	
prt_comma:			;function to print comma and space
	mov eax, SYSCALL_WRITE
	mov ebx, STDOUT
	mov ecx, comma
	mov edx, 1
	int 080h
	
	mov eax, SYSCALL_WRITE
	mov ebx, STDOUT
	mov ecx, space
	mov edx, 1
	int 080h
	
	ret