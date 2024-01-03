OUTPUT_ARCH( "riscv" )
ENTRY( _start )

SECTIONS
{
    /* 0x1000: Instruction */
    . = 0x1000;
    .text : { *(.text) }
    /* 0x4000: Data */
    . = 0x4000;
    .data : { *(.data) }
    .bss : { *(.bss) }
}
