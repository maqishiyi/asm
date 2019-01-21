;硬盘主引导扇区代码
;从实模式进入保护模式

;设置堆栈段和指针
mov ax, cs
mov ss, ax
mov sp, 0x7c00

;计算GDT所在的逻辑段地址
mov ax, [cs:gdt_base+0x7c00]
mov dx, [cs:gdt_base+0x7c00+0x02]
mov bx, 16
div bx
mov ds, ax
mov bx, dx

;创建0#描述符，它是空描述符，这是处理器的要求
mov dword [bx+0x00], 0x00
mov dword [bx+0x04], 0x00

;创建#1描述符，保护模式下的代码段描述符
mov dword [bx+0x08], 0x7c0001ff
mov dword [bx+0x0c], 0x00409800

;创建#2描述符，保护模式下的数据段描述符(文本模式下的显示缓冲区
mov dword [bx+0x10], 0x8000ffff
mov dword [bx+0x14], 0x0040920b

;创建#3描述符，保护模式下的堆栈段描述符
mov dword [bx+0x18], 0x00007a00
mov dword [bx+0x1c], 0x00409600

;初始化描述符表寄存器GDTR
mov word [cs: gdt_size+0x7c00], 31 ;描述符表的界限，总字节数-1

lgdt [cs: gdt_size+0x7c00]

in al, 0x92           ;南桥芯片内的端口
or al, 0000_0010B
out 0x92, al          ;打开A20

cli                   ;保护模式下中断机制尚未建立，应禁止中断

mov eax, cr0
or  eax, 1
mov cr0, eax          ;设置PE位为1

;以下进入保护模式
jmp dword 0x0008:flush

[bits 32]

flush:







