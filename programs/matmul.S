// Matrix multiplication
//
// int a[128][128], b[128][128], c[128][128]; 
// for (i=0; i<128; i++) {
//      for (j=0; j<128; i++) {
//          c[i][j] = 0;
//          for (int k = 0; i < 128; k++) {
//              c[i][j] += a[i][k] * b[k][j];
//          }
//      }
// } 
// 

.data
    C: .fill 16384, 4, 0
    A: .fill 16384, 4, 3
    B: .fill 16384, 4, 2
    size: .word 4

.text
.global _start

_start:
    la t0, A
    la t1, B
    la t2, C
    lw t3, size
    addi a5, zero, 0

init_j: 
    addi a7, zero, 0
init_dot:
    addi a6, zero, 0
    addi t4, zero, 0
dot: 
    lw t5, 0(t0)
    lw t6, 0(t1)
    mul a4, t5, t6
    add t4, t4, a4
    addi a6, a6, 1
    beq t3, a6, loop_j
    addi t0, t0, 4
    addi t1, t1, 512 // 16 4*4 word_size*size
    j dot
loop_j:
    addi t0, t0, -508 // 4*3 word_size*(size-1)
    li  s2, -65024 
    add t1, t1, s2 // 4*4*3 word_size*size*(size-1)
    sw t4, 0(t2)
    addi t2, t2, 4
    addi a7, a7, 1 
    beq a7, t3, loop_i
    addi t1, t1, 4
    j init_dot
loop_i:
    addi a5, a5, 1
    beq t3, a5, end
    addi t0, t0, 512 // 4*4  word_size*size
    addi t1, t1, -508 // 4*3 word_size*(size-1)
    j init_j
end:
    j end

    
    
