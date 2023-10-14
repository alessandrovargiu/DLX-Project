addi r1, r0, #65535;    2001FFFF
addi r2, r0, #-1;       2002FFFF
nop;                    54000000
add r3, r1, r1;         00211820
add r4, r1, r2;         00222020
nop;                    54000000

# raw hazard i-type tests
addi r1, r0, #10;       2001000A
andi r2, r1, #3;        30220003
ori r3, r1, #3;         34230003
xori r4, r1, #11;       3824000B
xnori r5, r1, #10;      7825000A
sgei r6, r1, #3;        74260003
slei r7, r1, #15;       7027000F
nori r8, r1, #4;        7C280004
nandi r8, r1, #7;       A8280007
lw r1, 7(r8);           8D010007
subi r3, r1, #6;        28230006

# shift testing
addi r1, r0, #10;                       2001000A
addi r2, r0, #2;        ;shift amount   20020002
sll r3, r1, r2;         ;R3 = R1 << R2  00221804
srl r4, r3, r2;         ;R4, R3 >> R2   00622006
sra r5, r3, r2;         ;R5, R3 >>> R2  00622807
srai r6, r3, #5;                        5C660005
slli r7, r3, #5;                        50670005

# small loop with RAW
addi r10, r0, #5;       200A0005
addi r11, r0, #2;       200B0002
loop:
seq r12, r10, r11;      014B6028
sne r13, r10, r11;      014B6829
sge r14, r10, r11;      014B702D
sle r15, r10, r11;      014B782C
subi r10, r10, #1;      294A0001
bnez r10, loop;         15400020
jal point;              0C000004
add r0, r10, r5;        01450020
point:
addi r1, r0, #1;        20010001
addui r2, r1, #65535;   2422FFFF
addi r3, r1, #32767;    20237FFF
addui r4, r1, #32767;   24247FFF

# another loop with load/store
lw r10, 5(r1);      8C2A0005
addi r4, r0, #5;    20040005

loop:
andi r3, r1, #1;    30230001
xori r3, r3, #1;    38630001
slli r1, r1, #15;   5021000F
srli r1, r1, #1;    58210001
or r2, r2, r3;      00431025
subi r4, r4, #1;    28840001
bnez r4, loop;      1480FFE4







