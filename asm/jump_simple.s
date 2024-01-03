            addi x4, zero, 9
LOOP_START: addi x1, zero, 1
            addi x2, zero, 2
            add  x3, zero, x1
NOT_TAKEN:  beq x1, x2, INVALID
            addi x4, x4, -1
            beq x4, zero, END
            jal x10, LOOP_START
END:        beq x1, x3, END
INVALID:    nop
