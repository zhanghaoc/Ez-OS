;程序源代码（myos1.asm）
org  7c00h ;引导扇区 0-7c00h是内核代码（大概）
;org  100h ;.com
;org 0h ;都不要是bin,即本条
;也可以使用vstart=0x7c00
;符号地址计算要加org的值
;这是因为我们写的程序实际上从7c00h开始

; BIOS将把引导扇区加载到0:7C00h处，并开始执行
OffSetOfUserPrg equ 8100h ;?感觉这里8000h就行
backColor equ 0x3e

%macro printStr 4 ;地址，长度，x位置，y位置
	mov	bp, %1		 ; BP=当前串的偏移地址
	mov	ax, ds		 ; ES:BP = 串地址
	mov	es, ax		 ; 置ES=DS
	mov	cx, %2       ; CX = 串长（=9）
	mov	ax, 1301h	 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 003eh	 ; 页号为0(BH = 0) 青底黄字(BL = 07h) H+L=X
    mov dh, %3		 ; 行号=0
	mov	dl, %4		 ; 列号=0
	int	10h			 ; BIOS的10h功能：显示一行字符
%endmacro

Start:
	MOV AH, 06h    ; Scroll up function
	XOR AL, AL     ; Clear entire screen
	XOR CX, CX     ; Upper left corner CH=row, CL=column
	MOV DX, 184FH  ; lower right corner DH=row, DL=column 
	MOV BH, backColor    ; YellowOnBlue
	INT 10H

	mov	ax, cs	       ; 置其他段寄存器值与CS相同;cs值是BIOS跳转赋值的，运行期间才知道
	mov ss, ax			;栈指针也指向段地址
	mov	ds, ax	       ; 数据段
	printStr Message, Message1Len, 0, (80-Message1Len)/2 
	printStr Message2, Message2Len, 1, (80-Message2Len)/2 

LoadnEx:
      ;读取键盘输入 
	  mov ah, 0
	  int 16h
	  cmp al, '1'
		jl LoadnEx
	  cmp al, '4'
		jg LoadnEx
	  
	  sub al, '0'
	  mov cl, al
	  add cl, cl
	  
	  mov ax,cs                ;段地址 ; 存放数据的内存基地址
      mov es,ax                ;设置段地址（不能直接mov es,段地址）
	  mov ss, ax				
      mov bx, OffSetOfUserPrg ;偏移地址; 存放数据的内存偏移地址
      mov ah,2                 ; 功能号 2是读，1是写
      mov al,2                 ;扇区数,由于程序比较大，每个程序2个扇区
      mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
      mov dh,0                 ;磁头号 ; 起始编号为0
      mov ch,0                 ;柱面号 ; 起始编号为0
      ;mov cl,2                 ;起始扇区号 ; 起始编号为1
      int 13H ;                调用读磁盘BIOS的13h功能
	  
      call far [newAddr]
	  jmp Start
		
AfterRun:
      jmp $                      ;无限循环
datadef:
      Message db 'Hello, welcome to zhxOS!'
	  Message1Len  equ ($-Message)
	  Message2 db 'please input a number between 1 and 4'
	  Message2Len  equ ($-Message2)
	  newAddr dw 0x0100, 0x0800
      times 510-($-$$) db 0
      db 0x55,0xaa

