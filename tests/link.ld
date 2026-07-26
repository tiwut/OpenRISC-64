OUTPUT_ARCH(riscv)
ENTRY(_start)

SECTIONS
{
    /* Our PC is hardcoded to boot at 0x80000000 */
    . = 0x80000000;
    
    .text : {
        *(.text.init)
        *(.text .text.*)
    }

    .rodata : {
        *(.rodata .rodata.*)
    }

    .data : {
        _data_start = .;
        *(.data)
    }
    
    .bss : {
        *(.bss)
    }
}
