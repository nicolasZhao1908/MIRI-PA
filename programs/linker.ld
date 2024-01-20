OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
    . = 0x1000;
    .text : { *(.text) }
    . = 0x2000;
    .xcpt : { *(.xcpt) }
    . = 0x4000;
    .data : { *(.data) }
}