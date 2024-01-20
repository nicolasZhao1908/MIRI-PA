// Mem copy
//
// int a[128], b[128]; 
// for (i=0; i<128; i++) { a[i] = 5; } 
// for (i=0; i<128; i++) { b[i] = a[i]; }

.data
    b: .fill 128,4,0
    a: .fill 128,4,1
    length: .word 128

.text
.global _start

_start:
    la t1, a // int* a = a_addr
    la t2, b // int* b = b_addr
    lw t3, length // mem[length_addr]
    addi t4, zero, 0 // int i = 0
    addi t5, zero, 5 // value to store in a[i]
init_a:
    beq t4, t3, reset // if (i == length) goto reset;
    sw t5, 0(t1) // mem[a_addr] = 5
    addi t1, t1, 4 // a_addr += 4
    addi t4, t4, 1 // i += 1
    j init_a
reset:  
    la t1, a // int* a = a_addr
    addi t4, zero, 0 // int i = 0
copy:
    beq t4, t3, end // if (i == length) goto end;
    lw t5, 0(t1) // aux = mem[a_addr]
    sw t5, 0(t2) // mem[b_addr] = aux
    addi t1, t1, 4 // a_addr += 4
    addi t2, t2, 4 // b_addr += 4
    addi t4, t4, 1 // i += 1
    j copy
end:
    j end

