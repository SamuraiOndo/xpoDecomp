SECTIONS
{
    __romPos = 0;
    _gp = 0x800963A8;
    header_ROM_START = __romPos;
    header_VRAM = ADDR(.header);
    .header : AT(header_ROM_START) SUBALIGN(2)
    {
        FILL(0x00000000);
        header_DATA_START = .;
        build/asm/header.o(.data);
        header_DATA_END = .;
        header_DATA_SIZE = ABSOLUTE(header_DATA_END - header_DATA_START);
    }
    __romPos += SIZEOF(.header);
    header_ROM_END = __romPos;
    header_VRAM_END = .;
    main_ROM_START = __romPos;
    main_VRAM = ADDR(.main);
    .main 0x80018000 : AT(main_ROM_START) SUBALIGN(2)
    {
        FILL(0x00000000);
        main_RODATA_START = .;
        build/asm/data/rdata.rodata.o(.rodata);
        build/asm/text.o(.rodata);
        . = ALIGN(., 2);
        main_RODATA_END = .;
        main_RODATA_SIZE = ABSOLUTE(main_RODATA_END - main_RODATA_START);
        main_TEXT_START = .;
        build/asm/text.o(.text);
        . = ALIGN(., 2);
        main_TEXT_END = .;
        main_TEXT_SIZE = ABSOLUTE(main_TEXT_END - main_TEXT_START);
        main_DATA_START = .;
        build/asm/data/rdata.rodata.o(.data);
        build/asm/text.o(.data);
        build/asm/data/data.data.o(.data);
        . = ALIGN(., 2);
        main_DATA_END = .;
        main_DATA_SIZE = ABSOLUTE(main_DATA_END - main_DATA_START);
        main_SDATA_START = .;
        build/asm/data/sdata.sdata.o(.sdata);
        . = ALIGN(., 2);
        main_SDATA_END = .;
        main_SDATA_SIZE = ABSOLUTE(main_SDATA_END - main_SDATA_START);
    }
    main_bss_VRAM = ADDR(.main_bss);
    .main_bss (NOLOAD) : SUBALIGN(2)
    {
        FILL(0x00000000);
        main_SBSS_START = .;
        build/asm/data/sbss.sbss.o(.sbss);
        . = ALIGN(., 2);
        main_SBSS_END = .;
        main_SBSS_SIZE = ABSOLUTE(main_SBSS_END - main_SBSS_START);
        main_BSS_START = .;
        build/asm/data/rdata.rodata.o(.bss);
        build/asm/text.o(.bss);
        build/asm/data/bss.bss.o(.bss);
        . = ALIGN(., 2);
        main_BSS_END = .;
        main_BSS_SIZE = ABSOLUTE(main_BSS_END - main_BSS_START);
    }
    __romPos += SIZEOF(.main);
    __romPos = ALIGN(__romPos, 2);
    . = ALIGN(., 2);
    main_ROM_END = __romPos;
    main_VRAM_END = .;
    padding_ROM_START = __romPos;
    padding_VRAM = ADDR(.padding);
    .padding 0x0 : AT(padding_ROM_START) SUBALIGN(2)
    {
        FILL(0x00000000);
        padding_DATA_START = .;
        build/asm/data/padding.data.o(.data);
        padding_DATA_END = .;
        padding_DATA_SIZE = ABSOLUTE(padding_DATA_END - padding_DATA_START);
    }
    __romPos += SIZEOF(.padding);
    padding_ROM_END = __romPos;
    padding_VRAM_END = .;
    /DISCARD/ :
    {
        *(*);
    }
}
