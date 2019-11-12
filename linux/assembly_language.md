+ mov
```
MOV
功能: 把源操作数送给目的操作数
语法: MOV 目的操作数,源操作数
格式: MOV r1,r2
MOV r,m
MOV m,r
MOV r,data
```
+ call | ret
```
CALL,RET
功能: 子程序调用,返回指令
语法: CALL 地址 RET RET n
标志位: 无
``` 
+ jmp
```
JMP
功能: 跳往指定地址执行
语法: JMP 地址
``` 
+ int 
```
INT,IRET
功能: 中断调用及返回指令
语法: INT n IRET
标志位: 在执行INT时,CPU会自动将标志寄存器的值入栈,在执行IRET时则会将堆栈中的标志值弹回寄存器
字符串操作指令集
```
+ add
```
ADD,ADC
功能: 加法指令
语法: ADD OP1,OP2 ADC OP1,OP2
格式: ADD r1,r2 ADD r,m ADD m,r ADD r,data
影响标志: C,P,A,Z,S,O
``` 
+ or | xor
```
AND,OR,XOR,NOT,TEST
功能: 执行BIT与BIT之间的逻辑运算
语法: AND r/m,r/m/data OR r/m,r/m/data XOR r/m,r/m/data TEST r/m,r/m/data NOT r/m
影响标志: C,O,P,Z,S(其中C与O两个标志会被设为0) NOT指令不影响任何标志位
```
+ shl | shr
```
SHR,SHL,SAR,SAL
功能: 移位指令
语法: SHR r/m,data/CL SHL r/m,data/CL SAR r/m,data/CL SAL r/m,data/CL
影响标志: C,P,Z,S,O
```
+ push | pop
```
功能: 把操作数压入或取出堆栈
语法: PUSH 操作数 POP 操作数
格式: PUSH r PUSH M PUSH data POP r POP m
```
+ inc | dec 
```
功能: 把OP的值加一或减一
语法: INC OP DEC OP
格式: INC r/m DEC r/m
影响标志: P,A,Z,S,O
```
+ sub 
```
功能:减法指令
语法: SUB OP1,OP2 SBB OP1,OP2
格式: SUB r1,r2 SUB r,m SUB m,r SUB r,data SUB m,data
影响标志: C,P,A,Z,S,O
```
+ cmp
```
CMP
功能: 比较OP1与OP2的值
语法: CMP r/m,r/m/data
标志位: C,P,A,Z,O
```