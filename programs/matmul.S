// Matmul

.data
    matrixA: .fill 16, 4, 1
    matrixB: .fill 16, 4, 2
    matrixC: .fill 16, 4, 0
    size: .word 4

.text
.global _start

_start:
	lw a0, size
	la a1, matrixA
	la a2, matrixB
	la a3, matrixC
	
	addi t0, a1, 0
	addi t1, a2, 0
	


	li t6, 0
	li t5, 0
col:
			
    li t2, 0
	li t4, 0
inner:
	beq t4, a0, store

	lw t3, 0(t0)
	lw a4, 0(t1)

	add t3, t3, a4 //NORMALLY A MUL!
	add t2, t2, t3
	
	addi t1, t1, 16 // size * 4
	addi t0, t0, 4
	addi t4, t4, 1

	j inner
	
store:
	sw t2, 0(a3)
	addi a3, a3, 4
	# RESET
	addi t0, t0, -16 // -size * 4
	addi t1, t1, -60 // -size * size * 4 + 4

	addi t5, t5, 1
	beq t5, a0, inc_row

	j col
inc_row:
	li t5, 0
	
	addi t0, t0, 16 // size * 4
	addi t1, a2, 0
	addi t6, t6, 1
	
	beq t6, a0, end
	j col
end:
	j end