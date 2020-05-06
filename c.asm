; ����Դ���루stone.asm��
; ���������ı���ʽ��ʾ���ϴ�������һ��*��,��45���������˶���ײ���߿����,�������.
; ����� 2020/03/15
; NASM����ʽ
; �������ַC:\Users\Lenovo\Documents\Virtual Machines\MS-DOS
    Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
    Up_Rt equ 2                  ;
    Up_Lt equ 3                  ;
    Dn_Lt equ 4                  ;
    delay equ 50000			  ; ��ʱ���ӳټ���,���ڿ��ƻ�����ٶ�
    ddelay equ 1160				  ; ��ʱ���ӳټ���,���ڿ��ƻ�����ٶ�
	zuokuang equ 1
	youkuang equ 40
	shangkuang equ 14
	xiakuang equ 23
	backColor equ 0x5c
	textLen equ (block-mytext)
;org 8100h ;org֮�������datadefΪ���ݶλ�ַ
org 100h
jmp start
	 
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt        ; �������˶�
    x    dw 19			;��ʼλ��
    y    dw 7			
	;"18340207  ZhangHaoxi" 20 �� char (80-20)/2=30
	mytext db '18340207 ZhangHaoxi',0x1,' press ctrl+c to quit'
	;" ������ "�����ǰ���
	block db 0,backColor,219,0x0f,219,0x0f,219,0x0f,0,backColor 
	
	
;   ASSUME cs:code,ds:code
;   code SEGMENT
start:	
	;����������Ļ����ɫ
	MOV AH, 06h    ; Scroll up function
	XOR AL, AL     ; Clear entire screen
	XOR CX, CX     ; Upper left corner CH=row, CL=column
	MOV DX, 184FH  ; lower right corner DH=row, DL=column 
	MOV BH, backColor    ; YellowOnBlue
	INT 10H
	
	mov ax,cs
	mov ds,ax

	mov ax,0B800h				; �ı������Դ���ʼ��ַ
	mov es,ax					; GS = B800h
	
	;������ʾ����
	mov si,mytext
	mov di,(80-textLen)/2*2	  ;�ճ�30���ַ�
	mov cx, block-mytext      ;ʵ���ϵ��� 13
@g:
	mov al,[si]
	mov [es:di],al
	inc di
	mov byte [es:di],backColor
	inc di
	inc si
	loop @g
	
loop1:
	dec word[count]				; �ݼ���������
	jnz loop1					; >0����ת;
	mov word[count],delay
	dec word[dcount]				; �ݼ��������� ����ѭ��
    jnz loop1
	mov word[dcount],ddelay
	

	;����һ��С��λ���ÿո񸲸�
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
	  jmp show ;��ȥ
	
show:	
    ;������
	mov si,block
	mov ax,(shangkuang)*80*2-4 ;(shangkuang)*80*2-4;���ڴӰװ�����߿�ʼ������Ҫ��ȥ4
	add ax,word[y]
	add ax,word[y] ;y��ʾ�ǵ�y�У���Ļ��ÿ���ַ�ռ�����ֽ�
	mov di,ax
	mov cx,5      
	rep movsw
	
	mov si,block
	add di,160*(xiakuang-shangkuang)-10 ;�����(xiakuang-shangkuang)*80���գ��ټ�ȥ����5���գ�ÿ����ռ���ֽ�
	mov cx,5      
	rep movsw
	
	;���߿�
	mov bx,((shangkuang-1)*80+zuokuang)*2		;162��ʼ��((shangkuang-1)*80+zuokuang)*2 +zuokuang-1;�߽ǿ���
	mov ax,205+backColor*256 ;205������asc��
DrawUp:	
	mov [es:bx],ax  		;  ��ʾ�ַ���ASCII��ֵ
	add bx, 2
	cmp bx, ((shangkuang-1)*80+zuokuang)*2 + (youkuang-zuokuang+1)*2		;318 = ((shangkuang-1)*80+1)*2 + (youkuang-zuokuang)*2
	  jnz DrawUp
	
	mov bx,((xiakuang+1)*80+zuokuang)*2		;3842��ʼ��((xiakuang+1)*80+1)*2
DrawDown:					
	mov [es:bx],ax  		;  ��ʾ�ַ���ASCII��ֵ
	add bx, 2
	cmp bx, ((xiakuang+1)*80+zuokuang)*2 + (youkuang-zuokuang+1)*2	;3998((xiakuang+1)*80+1)*2 + (youkuang-zuokuang)*2
	  jnz DrawDown
	  
	mov bx,((shangkuang)*80+zuokuang-1)*2	;32(shangkuang)*80*2
	mov al,179
DrawLeft:
	mov [es:bx],ax  		;  ��ʾ�ַ���ASCII��ֵ
	add bx, 160
	cmp bx, ((shangkuang)*80+zuokuang-1)*2+(xiakuang-shangkuang+1)*160	;3840(shangkuang)*80*2+(xiakuang-shangkuang+1)*160
	  jnz DrawLeft
	  
	mov bx,((shangkuang)*80+zuokuang)*2+(youkuang-zuokuang+1)*2		;478(shangkuang)*80*2+(youkuang-zuokuang+1)*2
DrawRight:
	mov [es:bx],ax  		;  ��ʾ�ַ���ASCII��ֵ
	add bx, 160
	cmp bx,((shangkuang)*80+zuokuang)*2+(youkuang-zuokuang+1)*2+(xiakuang-shangkuang+1)*160	;3398(shangkuang)*80*2+(youkuang-zuokuang+1)*2+(xiakuang-shangkuang+1)*160
	  jnz DrawRight
	
    mov ax,word[x]
	mov bx,80
	mul bx
	add ax,word[y]
	mov bx,2				;80*25������ һ���������ı�������*2���ֽ����
	mul bx
	mov bx,ax
	mov ax, 2+backColor*256		;  �ַ�asc��Ϊ2����һ��Ц��
	mov [es:bx],ax  		;  ��ʾ�ַ���ASCII��ֵ
	
	mov ah, 01h
	int 16H
	  jz loop1				;��������ʱ��ZF=1�����·���������loop1
	mov ah, 00h				;�ӻ�������ȡ�ַ�����remove,����Ҫ�ٵ���һ��00h
	int 16H
	cmp ax, 2e03h			;�ж������Ƿ���ctrl+c,�Ƚ�asc�루ah��ɨ���룩
	  jne loop1				;���벻��ctrl+c, ���·���������loop1
	
	;pop ax					;���ǵ��ڴ���4MB�Լ���س���פ��ֱ��������ջ�б����ַ����
	;jmp ax
	retf
	
_end:
    jmp $                   ; ֹͣ��������ѭ�� 
	
;code ENDS
;     END start
