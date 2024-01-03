START:     addi x1, zero, 1
           addi x2, zero, 2
           add  x3, zero, x1
NOT_TAKEN: beq x1, x2, INVALID
END:       beq x1, x3, END
INVALID:   nop

# x1 = 1
# x2 = 2
# x3 = 1
