OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
    /* boots at 0x1000*/
    . = 0x1000;
    .text : { *(.text) }

    /* xcpt code at 0x2000*/

    /* data at 0x4000 */
    . = 0x4000;
    .data : { *(.data) }
    .bss : { *(.bss) }
}