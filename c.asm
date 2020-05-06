; 程序源代码（stone.asm）
; 本程序在文本方式显示器上从左边射出一个*号,以45度向右下运动，撞到边框后反射,如此类推.
; 张昊熹 2020/03/15
; NASM汇编格式
; 虚拟机地址C:\Users\Lenovo\Documents\Virtual Machines\MS-DOS
    Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
    Up_Rt equ 2                  ;
    Up_Lt equ 3                  ;
    Dn_Lt equ 4                  ;
    delay equ 50000			  ; 计时器延迟计数,用于控制画框的速度
    ddelay equ 1160				  ; 计时器延迟计数,用于控制画框的速度
	zuokuang equ 1
	youkuang equ 40
	shangkuang equ 14
	xiakuang equ 23
	backColor equ 0x5c
	textLen equ (block-mytext)
;org 8100h ;org之后就能用datadef为数据段基址
org 100h
jmp start
	 
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt        ; 向右下运动
    x    dw 19			;起始位置
    y    dw 7			
	;"18340207  ZhangHaoxi" 20 个 char (80-20)/2=30
	mytext db '18340207 ZhangHaoxi',0x1,' press ctrl+c to quit'
	;" ■■■ "这里是板子
	block db 0,backColor,219,0x0f,219,0x0f,219,0x0f,0,backColor 
	
	
;   ASSUME cs:code,ds:code
;   code SEGMENT
start:	
	;绘制整个屏幕背景色
	MOV AH, 06h    ; Scroll up function
	XOR AL, AL     ; Clear entire screen
	XOR CX, CX     ; Upper left corner CH=row, CL=column
	MOV DX, 184FH  ; lower right corner DH=row, DL=column 
	MOV BH, backColor    ; YellowOnBlue
	INT 10H
	
	mov ax,cs
	mov ds,ax

	mov ax,0B800h				; 文本窗口显存起始地址
	mov es,ax					; GS = B800h
	
	;居中显示名字
	mov si,mytext
	mov di,(80-textLen)/2*2	  ;空出30个字符
	mov cx, block-mytext      ;实际上等于 13
@g:
	mov al,[si]
	mov [es:di],al
	inc di
	mov byte [es:di],backColor
	inc di
	inc si
	loop @g
	
loop1:
	dec word[count]				; 递减计数变量
	jnz loop1					; >0：跳转;
	mov word[count],delay
	dec word[dcount]				; 递减计数变量 二次循环
    jnz loop1
	mov word[dcount],ddelay
	

	;将上一处小球位置用空格覆盖
	mov ah,backColor
	mov al,0
	mov [es:bx],ax
	
    mov al,1
    cmp al,byte[rdul]
	jz  DnRt
      mov al,2
      cmp al,byte[rdul]
	jz  UpRt
      mov al,3
      cmp al,byte[rdul]
	jz  UpLt
      mov al,4
      cmp al,byte[rdul]
	jz  DnLt

DnRt:
; if(x == 25) call dr2ur;
; else if(y == 80) call dr2dl;
; else call show
	inc word[x]
	inc word[y]
	
	cmp word[x],xiakuang
      jz  dr2ur
	cmp word[y],youkuang
      jz  dr2dl
	jmp show
dr2ur:
      mov word[x],xiakuang-2
      mov byte[rdul],Up_Rt	
      jmp show
dr2dl:
      mov word[y],youkuang-2
      mov byte[rdul],Dn_Lt	
      jmp show

UpRt:
	dec word[x]
	inc word[y]
	cmp word[y],youkuang
      jz  ur2ul
	cmp word[x],shangkuang
      jz  ur2dr
	jmp show
ur2ul:
      mov word[y],youkuang-2
      mov byte[rdul],Up_Lt	
      jmp show
ur2dr:
      mov word[x],shangkuang+2
      mov byte[rdul],Dn_Rt	
      jmp show
	
UpLt:
	dec word[x]
	dec word[y]
	cmp word[x],shangkuang
      jz  ul2dl
	cmp word[y],zuokuang
      jz  ul2ur
	jmp show

ul2dl:
      mov word[x],shangkuang+2
      mov byte[rdul],Dn_Lt	
      jmp show
ul2ur:
      mov word[y],zuokuang
      mov byte[rdul],Up_Rt	
      jmp show
	
DnLt:
	inc word[x]
	dec word[y]
	cmp word[y],zuokuang
      jz  dl2dr
	cmp word[x],xiakuang
      jz  dl2ul
	jmp show

dl2dr:
      mov word[y],zuokuang+2
      mov byte[rdul],Dn_Rt	
      jmp show
dl2ul:
      mov word[x],xiakuang-2
      mov byte[rdul],Up_Lt	
	  jmp show ;可去
	
show:	
    ;画挡板
	mov si,block
	mov ax,(shangkuang)*80*2-4 ;(shangkuang)*80*2-4;由于从白板最左边开始画，需要减去4
	add ax,word[y]
	add ax,word[y] ;y表示是第y列，屏幕上每个字符占两个字节
	mov di,ax
	mov cx,5      
	rep movsw
	
	mov si,block
	add di,160*(xiakuang-shangkuang)-10 ;相隔了(xiakuang-shangkuang)*80个空，再减去板子5个空，每个空占两字节
	mov cx,5      
	rep movsw
	
	;画边框
	mov bx,((shangkuang-1)*80+zuokuang)*2		;162起始是((shangkuang-1)*80+zuokuang)*2 +zuokuang-1;边角空着
	mov ax,205+backColor*256 ;205是竖框asc码
DrawUp:	
	mov [es:bx],ax  		;  显示字符的ASCII码值
	add bx, 2
	cmp bx, ((shangkuang-1)*80+zuokuang)*2 + (youkuang-zuokuang+1)*2		;318 = ((shangkuang-1)*80+1)*2 + (youkuang-zuokuang)*2
	  jnz DrawUp
	
	mov bx,((xiakuang+1)*80+zuokuang)*2		;3842起始是((xiakuang+1)*80+1)*2
DrawDown:					
	mov [es:bx],ax  		;  显示字符的ASCII码值
	add bx, 2
	cmp bx, ((xiakuang+1)*80+zuokuang)*2 + (youkuang-zuokuang+1)*2	;3998((xiakuang+1)*80+1)*2 + (youkuang-zuokuang)*2
	  jnz DrawDown
	  
	mov bx,((shangkuang)*80+zuokuang-1)*2	;32(shangkuang)*80*2
	mov al,179
DrawLeft:
	mov [es:bx],ax  		;  显示字符的ASCII码值
	add bx, 160
	cmp bx, ((shangkuang)*80+zuokuang-1)*2+(xiakuang-shangkuang+1)*160	;3840(shangkuang)*80*2+(xiakuang-shangkuang+1)*160
	  jnz DrawLeft
	  
	mov bx,((shangkuang)*80+zuokuang)*2+(youkuang-zuokuang+1)*2		;478(shangkuang)*80*2+(youkuang-zuokuang+1)*2
DrawRight:
	mov [es:bx],ax  		;  显示字符的ASCII码值
	add bx, 160
	cmp bx,((shangkuang)*80+zuokuang)*2+(youkuang-zuokuang+1)*2+(xiakuang-shangkuang+1)*160	;3398(shangkuang)*80*2+(youkuang-zuokuang+1)*2+(xiakuang-shangkuang+1)*160
	  jnz DrawRight
	
    mov ax,word[x]
	mov bx,80
	mul bx
	add ax,word[y]
	mov bx,2				;80*25个文字 一个文字由文本和属性*2个字节组成
	mul bx
	mov bx,ax
	mov ax, 2+backColor*256		;  字符asc码为2，是一个笑脸
	mov [es:bx],ax  		;  显示字符的ASCII码值
	
	mov ah, 01h
	int 16H
	  jz loop1				;缓冲区空时，ZF=1，无事发生，跳回loop1
	mov ah, 00h				;从缓冲区获取字符不会remove,所以要再调用一次00h
	int 16H
	cmp ax, 2e03h			;判定输入是否是ctrl+c,比较asc码（ah是扫描码）
	  jne loop1				;输入不是ctrl+c, 无事发生，跳回loop1
	
	;pop ax					;考虑到内存有4MB以及监控程序常驻，直接跳回在栈中保存地址即可
	;jmp ax
	retf
	
_end:
    jmp $                   ; 停止画框，无限循环 
	
;code ENDS
;     END start
