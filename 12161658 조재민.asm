TITLE 12161658 Snake Game �����

INCLUDE	Irvine32.inc

.data

	StartingMenu BYTE "Press Number To Start Game", 0dh, 0ah, "1. Start Game", 0dh, 0ah,
					"2. Game Level", 0dh, 0ah, "3. Exit", 0dh, 0ah, 0dh, 0ah, "Created By. �� �֨ͨѨ٨ըڨϨԨ�", 0dh, 0ah, 0

	GameStartInstruction BYTE "Use Arrow Keys To Move Your Snake   (�� �� �� ��)", 0dh, 0ah, 
		  "                                         Press any button to Start!",0 


	Level BYTE "Select Difficulty", 0dh, 0ah, 0dh, 0ah, "1. Easy", 0dh, 0ah, "2. Normal", 0dh, 0ah,
			   "3. Hard", 0dh, 0ah, "4. Hell", 0dh, 0ah, 0

	gameOver BYTE " Game Over :) ", 0dh, 0ah, "                        Press 'R' To Restart, 'E' to Exit!" ,0

	ScoreBoard BYTE "����: ", 0

	GoodByeMessage BYTE "Good Bye :D ��", 0dh, 0ah, 0dh, 0ah, 0

	SnakeShow BYTE '��', 0
	FoodShow BYTE '��', 0

	search WORD 0d	
	TailCoord BYTE 1d	 ; 
	EndGameCheck BYTE 0d ; ������ �������� Ȯ���ϴ� ����
	ScoreCheck DWORD 0d  ; ���� Ȯ�κ���
	GameSpeedType DWORD 100	; �⺻���Ӽӵ� 100
	direction BYTE 'w' ; snake�� ����ġ ����
	DirectionNew BYTE 'w' 
	Controler DWORD ?
	variableB DWORD ?    ; ���ۼ����ϴ� input����
	InputVariable BYTE 16 DUP(?)
	ReadVariable DWORD ?   
	
	MinusRow BYTE 0d          ; ����ġ ��
	MinusColumn BYTE 0d       
	PlusRow BYTE 0d          
	PlusColumn BYTE 0d  

	TailColumn BYTE 47d    ;�� ���� �� ��ǥ
	TailRow BYTE 16d       ;�� ���� �� ��ǥ
	HeadColumn BYTE 47d    ;�� �Ӹ� �� ��ǥ
	HeadRow BYTE 13d       ;�� �Ӹ� �� ��ǥ
	FoodRow BYTE 0         ;���� �� ��ǥ
	FoodColumn BYTE 0      ;���� �� ��ǥ
	RowIndex BYTE 0        ;�� ��ǥ �ӽ�����ó
	ColumnIndex BYTE 0     ;�� ��ǥ �ӽ�����ó
	Frame WORD 1920 DUP(0) ;�ӵ����� ������ ����

.code
main PROC	; ����, ���ӽ���, �������� �����ְ� �����ϸ� gamestart ���ν����� �Ѿ��. ������ ������ �ٽ� ����� �Ĺ�
	
	start:	; ������ ������ ��� �ϱ� ���ؼ�.
	call Randomize	;������ ���� ECX�� �ִ´�
	call clrscr
	mov edx, OFFSET StartingMenu
	call writestring

	returnto:
	call readchar

	cmp al, '1'	; game ����
	je gamestart

	cmp al, '2'	; game ���� ����
	je gamelevel

	cmp al, '3'	; ����
	jne returnto ; 1,2,3 �� �ƴϸ� �ݺ�

	mov edx, OFFSET GoodByeMessage
	call crlf
	call WriteString
	call waitmsg
	exit

	gamelevel:	;�޴����� ���õ� ���ӷ���
	call clrscr
	mov edx, OFFSET Level
	call writestring

	returnto2:
	call readchar

	cmp al, '1'
	je SlowSpeed

	cmp al, '2'
	je NormalSpeed

	cmp al, '3'
	je HarderSpeed

	cmp al, '4'
	je HellSpeed
	
	jmp returnto2	;�߸��� �����̸� �ݺ�

	SlowSpeed:
	mov GameSpeedType, 150
	jmp start

	NormalSpeed:
	mov GameSpeedType, 100
	jmp start

	HarderSpeed:
	mov GameSpeedType, 50
	jmp start

	HellSpeed:
	mov GameSpeedType, 30
	jmp start

gamestart:

	call clrscr	; �޴�ȭ�� �����
	mov eax, 0	;����� �������͸� �ʱ�ȭ
	mov dh, 12
	mov dl, 30
	call gotoXY
	mov edx, OFFSET GameStartInstruction
	call WriteString
	call readchar
	cmp eax, " "
	je gstart

gstart:	
	call clrscr
	call FirstSnake	; ���� ���� ��ġ procedure
	call Food	; ���̸� ����� ȭ�鿡 ����ϴ� procedure
	call Game	; ���� ���� procedure
	mov eax, white + (black * 16)
	call SetTextColor
	jmp start ; �ٽ� start �޴��� ����

main ENDP

Game PROC USES EAX EBX ECX EDX	;��ǻ� ���� ���ν���, ó�� �������� ReadConsoleInput ���ν����� ���´�
	mov eax, white + (black * 16)
	call setTextColor
	mov dh, 24
	mov dl, 40
	call gotoXY
	mov edx, OFFSET ScoreBoard
	Call WriteString

	Invoke getStdHandle, STD_INPUT_HANDLE	; Windows���� �����ϴ� ��Ʈ�ѷ� procedure
	mov Controler, eax
	mov ecx, 10

recall:
	Invoke GetNumberOfConsoleInputEvents, Controler, Addr variableB
	mov ecx, variableB
	
	cmp ecx, 0
	je done

	Invoke ReadConsoleInput, Controler, ADDR InputVariable, 1, ADDR ReadVariable
	mov dx, WORD PTR InputVariable
	cmp dx, 1
	jne BackToMain

	mov dl, BYTE PTR [InputVariable + 4]
	cmp dl, 0
	je BackToMain
	mov dl, BYTE PTR [InputVariable + 10]

	cmp dl, 1Bh	; ESC �� ���ȳ� Ȯ��, �������� quit �ٽ� ���� ����
	je quit		
	
	cmp direction, 'w'	;���� ���� �̸� case1���� ����
	je case1
	cmp direction, 's' ;���ι������� �������ְ� case1���� ����
	je case1

	jmp case2

	case1:	; ���� �̵��ϴ� ���̽�,
		cmp dl, 25h
		je case11	
		cmp dl, 27h
		je case12
		jmp BackToMain

		case11:
			mov DirectionNew, 'a'	;���� ��������
			jmp BackToMain

		case12:
			mov DirectionNew, 'd'	;���� ������
			jmp BackToMain

	case2:
		cmp dl, 26h
		je case21
		cmp dl, 28h
		je case22
		jmp BackToMain

case21:
	mov DirectionNew, 'w'
	jmp BackToMain

case22:
	mov DirectionNew, 's'
	jmp BackToMain


BackToMain:
	jmp recall	; recall�� ���η����� ������

done:
	mov bl, DirectionNew

	mov direction, bl
	call MoveSnake	; ���ο� ����� ��ġ�� �ʱ�ȭ���ش�
	mov eax, GameSpeedType ;���Ӽӵ� ����
	call Delay
	
	cmp EndGameCheck, 1	; ���� �������� flag 1
	je quit

	jmp recall	; recall�� ���η��� ������

quit:
	call clearMem	; ������ �����ϸ� �ٽ� �������� ���ư������� ������ ������ �ʱ�ȭ���ش�
	mov GameSpeedType, 100

	ret

Game ENDP

MoveSnake PROC USES EBX EDX

	cmp TailCoord, 1	; ������ ���� Ȯ��
	jne NoTailCoord

	mov dh, TailRow	; dh�� �첿�� ��ǥ �ְ�
	mov dl, TailColumn	; dl���� �ְ�
	call accessFrame
	dec bx

	mov search, bx

	mov bx, 0
	call FrameValue

	call gotoXY	; ������ ��ǥ�� ����°�
	mov eax, white + (black * 16)
	call SetTextColor
	mov al, ' '
	call writechar
	
	push edx	; ������ ������ Ŀ���� �ű��
	mov dl, 79
	mov dh, 23
	call gotoXY
	pop edx

	mov al, dh
	dec al
	mov MinusRow, al
	add al, 2
	mov PlusRow, al

	mov al, dl
	dec al
	mov MinusColumn, al
	add al, 2
	mov PlusColumn, al

	cmp PlusRow, 24
	jne next1
	mov PlusRow, 0

next1:
	cmp PlusColumn, 80	; ��ǥ�� ������ �������� Ȯ��
	jne next2
	mov PlusColumn, 0

next2:
	cmp MinusRow, 0
	jge next3
	mov MinusRow, 23

next3:
	cmp MinusColumn, 0
	jge next4
	mov MinusColumn, 79

next4:
	mov dh, MinusRow
	mov dl, TailColumn
	call accessFrame
	cmp bx, search
	jne melseif1
	mov TailRow, dh
	jmp mendif

melseif1:
	mov dh, PlusRow
	call accessFrame
	cmp bx, search
	jne melseif2
	mov TailRow, dh
	jmp mendif

melseif2:
	mov dh, TailRow
	mov dl, MinusColumn
	call accessFrame
	cmp bx, search
	jne melse
	mov TailColumn, dl
	jmp mendif

melse:
	mov dl, PlusColumn
	mov TailColumn, dl

mendif:

NoTailCoord:
	mov TailCoord, 1
	mov dh, TailRow
	mov dl, TailColumn
	mov RowIndex, dh
	mov ColumnIndex, dl

whileTrue:
	mov dh, RowIndex
	mov dl, ColumnIndex
	call accessFrame
	dec bx

	mov search, bx

	push ebx
	add bx, 2
	call FrameValue
	pop ebx

	cmp bx, 0
	je break

	mov al, dh
	dec al
	mov MinusRow, al
	add al, 2
	mov PlusRow, al

	mov al, dl
	dec al
	mov MinusColumn, al
	add al, 2
	mov PlusColumn, al

	cmp PlusRow, 24
	jne next21
	mov PlusRow, 0

next21:
	cmp PlusColumn, 80
	jne next22
	mov PlusColumn, 0

next22:
	cmp MinusRow, 0
	jge next23
	mov MinusRow, 23

next23:
	cmp MinusColumn, 0
	jge next24
	mov MinusColumn, 79

next24:
	mov dh, MinusRow
	mov dl, ColumnIndex
	call accessFrame
	cmp bx, search
	jne elseif21
	mov RowIndex, dh
	jmp endif2

elseif21:
	mov dh, PlusRow
	call accessFrame
	cmp bx, search 
	jne elseif22
	mov RowIndex, dh
	jmp endif2

elseif22:
	mov dh, RowIndex
	mov dl, MinusColumn
	call accessFrame
	cmp bx, search
	jne else2
	mov ColumnIndex, dl
	jmp endif2

else2:
	mov dl, PlusColumn
	mov ColumnIndex, dl

endif2:
	jmp whileTrue

break:
	mov al, HeadRow
	dec al
	mov MinusRow, al
	add al, 2
	mov PlusRow, al

	mov al, HeadColumn
	dec al
	mov MinusColumn, al
	add al, 2
	mov PlusColumn, al

	cmp PlusRow, 24
	jne next31
	mov PlusRow, 0

next31:
	cmp PlusColumn, 80
	jne next32
	mov PlusColumn, 0

next32:
	cmp MinusRow, 0
	JGE next33
	mov MinusRow, 23

next33:
	cmp MinusColumn, 0
	jge next34
	mov MinusColumn, 79

next34:
	cmp direction, 'w'	;����Ȯ��
	jne elseif3
	mov al, MinusRow
	mov HeadRow, al
	jmp endif3

elseif3:
	cmp direction, 's'
	jne elseif32
	mov al, PlusRow
	mov HeadRow, al
	jmp endif3

elseif32:
	cmp direction, 'a'
	jne else3
	mov al, MinusColumn
	mov HeadColumn, al
	jmp endif3

else3:
	mov al, PlusColumn
	mov HeadColumn, al

endif3:
	mov dh, HeadRow
	mov dl, HeadColumn

	call accessFrame
	cmp bx, 0
	je KeepG

restart1:
	mov dh, 12
	mov dl, 30
	call gotoXY
	mov edx, OFFSET gameOver
	call writestring
	call readchar
	.IF al == 'r'
		jmp continueG
	.ELSEIF al == 'e'
		call crlf
		call waitmsg
		exit
	.ELSE
		jmp restart1

	.ENDIF
	continueG:
	mov EndGameCheck, 1

	ret

KeepG:
	mov bx, 1
	call FrameValue

	mov cl, FoodColumn
	mov ch, FoodRow

	cmp cl, dl
	jne NoEaten
	cmp ch, dh
	jne NoEaten

	call Food
	mov TailCoord, 0

	mov eax, white + (black * 16)
	call setTextColor

	push edx
	mov dh, 24
	mov dl, 47
	call gotoXY
	mov eax, ScoreCheck
	inc eax
	call writedec
	mov ScoreCheck, eax

	pop edx

NoEaten:
	call gotoXY
	mov eax, lightgreen + (black * 16)
	call setTextColor
	mov al, '0'
;	mov edx, OFFSET SnakeShow
;	call writestring
	call writechar
	mov dh, 24
	mov dl, 79
	call gotoXY

	ret

MoveSnake ENDP

FOOD PROC USES EAX EBX EDX

back:
	mov eax, 24
	call RandomRange
	mov dh, al

	mov eax, 80
	call RandomRange
	mov dl, al

	call accessFrame

	cmp bx, 0
	jne back

	mov FoodRow, dh
	mov FoodColumn, dl

	mov eax, Yellow + (Black * 16)	;���� �� ��� �ұ��~
	call setTextColor
	call gotoXY
	mov edx, OFFSET FoodShow
	call writestring

	ret

FOOD ENDP

FirstSnake PROC USES ebx edx ; ó�� ���� ��µǴ� �⺻������ ���ν���

    mov dh, 13      ; ù ���� ���� ���� ���� ����
    mov dl, 47      ; ù ���� ���� ���� ���� ����
    mov bx, 1       ; ù��° ���� ����
    call FrameValue  ; Frame�ȿ� ����

    mov dh, 14       
    mov dl, 47      
    mov bx, 2       
    call FrameValue 

    mov dh, 15
    mov dl, 47     
    mov bx, 3       
    call FrameValue 

    mov dh, 16     
    mov dl, 47   
    mov bx, 4   
    call FrameValue  

    ret
FirstSnake ENDP

FrameValue PROC USES EAX ESI EDX
; register�� Frame�� �Է��Ѵ�. ���� x��ǥ y��ǥ bx�� ���� �̵ȴ�
	push ebx
	mov bl, dh	; row�� bl�� �ִ´�
	mov al, 80	; 
	mul bl	; framebuffer ���׸�Ʈ�� 80�� ���Ѵ�
	push dx
	mov dh, 0	;���⼭���� coloum
	add ax, dx	; arrayindex�� �ִ´�
	pop dx	
	mov esi, 0
	mov si, ax
	pop ebx
	shl si, 1	;WORD Ÿ��
	mov Frame[si], bx	;frame �迭�� bx�� ����

	ret
FrameValue ENDP

accessFrame PROC USES EAX ESI EDX ;�� ���ν����� ���� �ȼ��� �������� ���Ѵ�, dh (��) dl(��), pixel���� bx�� ����											

	mov bl, dh
	mov al, 80
	mul bl
	push dx
	mov dh, 0
	add ax, dx
	pop dx
	mov esi, 0
	mov si, ax
	shl si, 1
	mov bx, Frame[si]

	ret
accessFrame ENDP

clearMem PROC	;Frame���� �ʱ�ȭ, ����ġ ��ǥ �ʱ�ȭ, ���Ӱ��� flag���� �� �ʱ�ȭ�Ѵ�

	mov dh, 0
	mov bx, 0

oLoop:
	cmp dh, 24
	je endOLoop
	mov dl, 0

	iLoop:
		cmp dl, 80
		je endILoop
		call FrameValue
		inc DL
		jmp iLoop

endILoop:
	inc dh
	jmp oLoop	;�ٽ� �� ������ ����

endOLoop:	;�ʱ�ȭ
	mov TailRow, 16	;��ǥ �ʱ�ȭ
	mov TailColumn, 47
	mov HeadRow, 13
	mov HeadColumn, 47
	mov EndGameCheck, 0
	mov TailCoord, 1
	mov direction, 'w'
	mov DirectionNew, 'w'
	mov ScoreCheck, 0

	ret
clearMem ENDP
END main