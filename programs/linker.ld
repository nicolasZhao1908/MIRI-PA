OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
    .text : {
        . = 0x1000;
         *(.text) 
        . = 0x2000;
         *(.xcpt) 
    }
    . = 0x4000;
    .data : { *(.data) }
}