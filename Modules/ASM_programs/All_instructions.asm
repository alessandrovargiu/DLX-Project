addi r1, r0, #65535;  
addi r2, r0, #-1;     
nop
add r3, r1, r1;       
add r4, r1, r2;
nop
# raw hazard i-type tests
addi r1, r0, #10;
andi r2, r1, #3;
ori r3, r1, #3;
xori r4, r1, #11;
xnori r5, r1, #10;
sgei r6, r1, #3;
slei r7, r1, #15;
nori r8, r1, #4;
nandi r8, r1, #7;

lw r1, 7(r8);
subi r3, r1, #6;

# shift testing
addi r1, r0, #10;       
addi r2, r0, #2;        ;shift amount    
sll r3, r1, r2;         ;R3 = R1 << R2
srl r4, r3, r2;         ;R4, R3 >> R2
sra r5, r3, r2;         ;R5, R3 >>> R2
srai r6, r3, #5;
slli r7, r3, #5;

# small loop with RAW
addi r10, r0, #5; 
addi r11, r0, #2;
loop:
seq r12, r10, r11;
sne r13, r10, r11;
sge r14, r10, r11;
sle r15, r10, r11;
subi r10, r10, #1;
bnez r10, loop;

jal point;
add r0, r10, r5;

point:
addi r1, r0, #1;
addui r2, r1, #65535;
addi r3, r1, #32767;
addui r4, r1, #32767;

# another loop with load/store

lw r10, 5(r1);
addi r4, r0, #5;
loop2:
andi r3, r1, #1;
xori r3, r3, #1;
slli r1, r1, #15;
srli r1, r1, #1;
or r2, r2, r3;

subi r4, r4, #1;
bnez r4, loop2;

sw 4(r2), r1;
