;����Դ���루myos1.asm��
org  7c00h ;�������� 0-7c00h���ں˴��루��ţ�
;org  100h ;.com
;org 0h ;����Ҫ��bin,������
;Ҳ����ʹ��vstart=0x7c00
;���ŵ�ַ����Ҫ��org��ֵ
;������Ϊ����д�ĳ���ʵ���ϴ�7c00h��ʼ

; BIOS���������������ص�0:7C00h��������ʼִ��
OffSetOfUserPrg equ 8100h ;?�о�����8000h����
backColor equ 0x3e

%macro printStr 4 ;��ַ�����ȣ�xλ�ã�yλ��
	mov	bp, %1		 ; BP=��ǰ����ƫ�Ƶ�ַ
	mov	ax, ds		 ; ES:BP = ����ַ
	mov	es, ax		 ; ��ES=DS
	mov	cx, %2       ; CX = ������=9��
	mov	ax, 1301h	 ; AH = 13h�����ܺţ���AL = 01h��������ڴ�β��
	mov	bx, 003eh	 ; ҳ��Ϊ0(BH = 0) ��׻���(BL = 07h) H+L=X
    mov dh, %3		 ; �к�=0
	mov	dl, %4		 ; �к�=0
	int	10h			 ; BIOS��10h���ܣ���ʾһ���ַ�
%endmacro

Start:
	MOV AH, 06h    ; Scroll up function
	XOR AL, AL     ; Clear entire screen
	XOR CX, CX     ; Upper left corner CH=row, CL=column
	MOV DX, 184FH  ; lower right corner DH=row, DL=column 
	MOV BH, backColor    ; YellowOnBlue
	INT 10H

	mov	ax, cs	       ; �������μĴ���ֵ��CS��ͬ;csֵ��BIOS��ת��ֵ�ģ������ڼ��֪��
	mov ss, ax			;ջָ��Ҳָ��ε�ַ
	mov	ds, ax	       ; ���ݶ�
	printStr Message, Message1Len, 0, (80-Message1Len)/2 
	printStr Message2, Message2Len, 1, (80-Message2Len)/2 

LoadnEx:
      ;��ȡ�������� 
	  mov ah, 0
	  int 16h
	  cmp al, '1'
		jl LoadnEx
	  cmp al, '4'
		jg LoadnEx
	  
	  sub al, '0'
	  mov cl, al
	  add cl, cl
	  
	  mov ax,cs                ;�ε�ַ ; ������ݵ��ڴ����ַ
      mov es,ax                ;���öε�ַ������ֱ��mov es,�ε�ַ��
	  mov ss, ax				
      mov bx, OffSetOfUserPrg ;ƫ�Ƶ�ַ; ������ݵ��ڴ�ƫ�Ƶ�ַ
      mov ah,2                 ; ���ܺ� 2�Ƕ���1��д
      mov al,2                 ;������,���ڳ���Ƚϴ�ÿ������2������
      mov dl,0                 ;�������� ; ����Ϊ0��Ӳ�̺�U��Ϊ80H
      mov dh,0                 ;��ͷ�� ; ��ʼ���Ϊ0
      mov ch,0                 ;����� ; ��ʼ���Ϊ0
      ;mov cl,2                 ;��ʼ������ ; ��ʼ���Ϊ1
      int 13H ;                ���ö�����BIOS��13h����
	  
      call far [newAddr]
	  jmp Start
		
AfterRun:
      jmp $                      ;����ѭ��
datadef:
      Message db 'Hello, welcome to zhxOS!'
	  Message1Len  equ ($-Message)
	  Message2 db 'please input a number between 1 and 4'
	  Message2Len  equ ($-Message2)
	  newAddr dw 0x0100, 0x0800
      times 510-($-$$) db 0
      db 0x55,0xaa

