// Buffer sum
//
// int a[128], sum = 0; 
// for (int i=0; i<128; i++) { 
//       sum += a[i]; 
// }

.data
    a: .fill 128, 4, 1
    length: .word 128
    sum: .word 0

.text
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
    la a1, sum   // int* sum;
    sw a0, 0(a1) // store result in sum
end:    
    j end
