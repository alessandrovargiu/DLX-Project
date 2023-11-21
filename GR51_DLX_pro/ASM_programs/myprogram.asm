lw r10, 5(r0);      8C2A0005
addi r4, r0, #3;    20040005
j loop;
addi r4, r0, #3;    
addi r5, r0, #3;    
addi r6, r0, #3;    
loop:
subi r4, r4, #1;    28840001
andi r3, r1, #1;    30230001
ori r3, r3, #1;    
srli r10, r10, #1;    
seq r6, r2, r5;    
bnez r4, loop;      1480FFE4
sw 4(r2), r1
