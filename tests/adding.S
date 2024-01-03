.data
    i: .word 10
    j: .word 20

.text
.global _start

_start:
    lw a2, i
    lw a3, j
    add a0, a2, a3
    la a1, j
    sw a0, 4(a1)
end:
    j end
