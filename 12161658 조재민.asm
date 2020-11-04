TITLE 12161658 Snake Game 조재민

INCLUDE	Irvine32.inc

.data

	StartingMenu BYTE "Press Number To Start Game", 0dh, 0ah, "1. Start Game", 0dh, 0ah,
					"2. Game Level", 0dh, 0ah, "3. Exit", 0dh, 0ah, 0dh, 0ah, "Created By. ㈜ ⓙⓐⓔⓜⓘⓝⓒⓗⓞ", 0dh, 0ah, 0

	GameStartInstruction BYTE "Use Arrow Keys To Move Your Snake   (▲ ◀ ▼ ▶)", 0dh, 0ah, 
		  "                                         Press any button to Start!",0 


	Level BYTE "Select Difficulty", 0dh, 0ah, 0dh, 0ah, "1. Easy", 0dh, 0ah, "2. Normal", 0dh, 0ah,
			   "3. Hard", 0dh, 0ah, "4. Hell", 0dh, 0ah, 0

	gameOver BYTE " Game Over :) ", 0dh, 0ah, "                        Press 'R' To Restart, 'E' to Exit!" ,0

	ScoreBoard BYTE "점수: ", 0

	GoodByeMessage BYTE "Good Bye :D ♡", 0dh, 0ah, 0dh, 0ah, 0

	SnakeShow BYTE '●', 0
	FoodShow BYTE '★', 0

	search WORD 0d	
	TailCoord BYTE 1d	 ; 
	EndGameCheck BYTE 0d ; 게임이 끝났는지 확인하는 변수
	ScoreCheck DWORD 0d  ; 점수 확인변수
	GameSpeedType DWORD 100	; 기본게임속도 100
	direction BYTE 'w' ; snake의 현위치 변수
	DirectionNew BYTE 'w' 
	Controler DWORD ?
	variableB DWORD ?    ; 버퍼설정하는 input변수
	InputVariable BYTE 16 DUP(?)
	ReadVariable DWORD ?   
	
	MinusRow BYTE 0d          ; 현위치 열
	MinusColumn BYTE 0d       
	PlusRow BYTE 0d          
	PlusColumn BYTE 0d  

	TailColumn BYTE 47d    ;뱀 꼬리 행 좌표
	TailRow BYTE 16d       ;뱀 꼬리 열 좌표
	HeadColumn BYTE 47d    ;뱀 머리 행 좌표
	HeadRow BYTE 13d       ;뱀 머리 열 좌표
	FoodRow BYTE 0         ;먹이 열 좌표
	FoodColumn BYTE 0      ;먹이 행 좌표
	RowIndex BYTE 0        ;열 좌표 임시저장처
	ColumnIndex BYTE 0     ;행 좌표 임시저장처
	Frame WORD 1920 DUP(0) ;속도조정 프레임 조정

.code
main PROC	; 메인, 게임시작, 설정등을 보여주고 시작하면 gamestart 프로시져로 넘어간다. 게임이 끝나면 다시 여기로 컴백
	
	start:	; 게임이 끝나도 계속 하기 위해서.
	call Randomize	;랜덤한 수를 ECX에 넣는다
	call clrscr
	mov edx, OFFSET StartingMenu
	call writestring

	returnto:
	call readchar

	cmp al, '1'	; game 시작
	je gamestart

	cmp al, '2'	; game 레벨 선택
	je gamelevel

	cmp al, '3'	; 종료
	jne returnto ; 1,2,3 이 아니면 반복

	mov edx, OFFSET GoodByeMessage
	call crlf
	call WriteString
	call waitmsg
	exit

	gamelevel:	;메뉴에서 선택된 게임레벨
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
	
	jmp returnto2	;잘못된 선택이면 반복

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

	call clrscr	; 메뉴화면 지우고
	mov eax, 0	;사용할 레지스터를 초기화
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
	call FirstSnake	; 최초 뱀의 위치 procedure
	call Food	; 먹이를 만들고 화면에 출력하는 procedure
	call Game	; 메인 게임 procedure
	mov eax, white + (black * 16)
	call SetTextColor
	jmp start ; 다시 start 메뉴로 간다

main ENDP

Game PROC USES EAX EBX ECX EDX	;사실상 메인 프로시져, 처음 시작으로 ReadConsoleInput 프로시져가 나온다
	mov eax, white + (black * 16)
	call setTextColor
	mov dh, 24
	mov dl, 40
	call gotoXY
	mov edx, OFFSET ScoreBoard
	Call WriteString

	Invoke getStdHandle, STD_INPUT_HANDLE	; Windows에서 제공하는 컨트롤러 procedure
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

	cmp dl, 1Bh	; ESC 가 눌렸나 확인, 눌렸으면 quit 다시 게임 시작
	je quit		
	
	cmp direction, 'w'	;세로 방향 이면 case1으로 간다
	je case1
	cmp direction, 's' ;가로방향으로 변경해주게 case1으로 점프
	je case1

	jmp case2

	case1:	; 왼족 이동하는 케이스,
		cmp dl, 25h
		je case11	
		cmp dl, 27h
		je case12
		jmp BackToMain

		case11:
			mov DirectionNew, 'a'	;방향 왼쪽으로
			jmp BackToMain

		case12:
			mov DirectionNew, 'd'	;방향 오른쪽
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
	jmp recall	; recall로 메인루프를 돌린다

done:
	mov bl, DirectionNew

	mov direction, bl
	call MoveSnake	; 새로운 방향과 위치를 초기화해준다
	mov eax, GameSpeedType ;게임속도 지정
	call Delay
	
	cmp EndGameCheck, 1	; 게임 끝났는지 flag 1
	je quit

	jmp recall	; recall로 메인루프 돌린다

quit:
	call clearMem	; 게임을 종료하면 다시 메인으로 돌아가기전에 설정된 값들을 초기화해준다
	mov GameSpeedType, 100

	ret

Game ENDP

MoveSnake PROC USES EBX EDX

	cmp TailCoord, 1	; 지나온 꼬리 확인
	jne NoTailCoord

	mov dh, TailRow	; dh에 뱀꼬리 좌표 넣고
	mov dl, TailColumn	; dl에도 넣고
	call accessFrame
	dec bx

	mov search, bx

	mov bx, 0
	call FrameValue

	call gotoXY	; 지나온 좌표를 지우는것
	mov eax, white + (black * 16)
	call SetTextColor
	mov al, ' '
	call writechar
	
	push edx	; 오른쪽 밑으로 커서를 옮긴다
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
	cmp PlusColumn, 80	; 좌표가 밖으로 나가는지 확인
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
	cmp direction, 'w'	;방향확인
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

	mov eax, Yellow + (Black * 16)	;먹이 를 어떻게 할까요~
	call setTextColor
	call gotoXY
	mov edx, OFFSET FoodShow
	call writestring

	ret

FOOD ENDP

FirstSnake PROC USES ebx edx ; 처음 뱀이 출력되는 기본설정값 프로시져

    mov dh, 13      ; 첫 시작 뱀의 꼬리 길이 세로
    mov dl, 47      ; 첫 시작 뱀의 꼬리 길이 가로
    mov bx, 1       ; 첫번째 뱀의 저장
    call FrameValue  ; Frame안에 들어간다

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
; register에 Frame을 입력한다. 각각 x좌표 y좌표 bx를 통해 이된다
	push ebx
	mov bl, dh	; row를 bl에 넣는다
	mov al, 80	; 
	mul bl	; framebuffer 세그먼트를 80에 곱한다
	push dx
	mov dh, 0	;여기서부터 coloum
	add ax, dx	; arrayindex에 넣는다
	pop dx	
	mov esi, 0
	mov si, ax
	pop ebx
	shl si, 1	;WORD 타입
	mov Frame[si], bx	;frame 배열에 bx값 저장

	ret
FrameValue ENDP

accessFrame PROC USES EAX ESI EDX ;이 프로시져를 통해 픽셀의 프레임을 정한다, dh (열) dl(행), pixel값은 bx에 저장											

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

clearMem PROC	;Frame등을 초기화, 뱀위치 좌표 초기화, 게임관련 flag등을 다 초기화한다

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
	jmp oLoop	;다시 밖 루프로 복귀

endOLoop:	;초기화
	mov TailRow, 16	;좌표 초기화
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