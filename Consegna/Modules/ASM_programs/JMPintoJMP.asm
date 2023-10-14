; infinite loop
start:
addi r1, r0, #10
ori r2, r1, #1
j point

addi r3, r0, #10
sra r4, r3, r3
point:
j start