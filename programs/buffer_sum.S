// Buffer sum
//
// int a[128], sum = 0; 
// for (int i=0; i<128; i++) { 
//       sum += a[i]; 
// }

.data
    sum: .word 0
    length: .word 128
    a: .fill 128, 4, 1

.section .text
.global _start
_start:
    addi t1, zero, 0 // int i = 0
    la t2, a         // int* a // auipc
    addi t3, zero, 0 // int sum = 0
    lw t4, length    // int length = 128
loop:
    beq t1, t4, endloop
    lw t5, 0(t2)       // aux = mem[sum + (a * i)]
    add t3, t3, t5     // sum += mem[sum + (a * i)]
    addi t2, t2, 4
    addi t1, t1, 1
    j loop
endloop:
    la a0, sum   // int* sum;
    sw t3, 0(a0) // store result in sum
    add t0, t0, 1
    lw t3, 64(a0) // check evict it WORKS   
end:    
    j end
