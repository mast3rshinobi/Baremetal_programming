
/* Memories definition */
MEMORY
{
  SRAM    (xrw)    : ORIGIN = 0x20000000,   LENGTH = 96K
  FLASH    (rx)    : ORIGIN = 0x8000000,   LENGTH = 512K
}

/* Sections */
SECTIONS
{
  .text :
  {
    *(.isr_vector)
    *(.text)
	    *(.text.*)
	    *(.init)
	    *(.fini)
	    *(.rodata)
	    *(.rodata.*)
	    . = ALIGN(4);
	    _etext = .;
  }> FLASH


_la_data = LOADADDR(.data);
  
  .data :
  {
    _sdata = .;
	    *(.data)
	    *(.data.*)
	    . = ALIGN(4);
	    _edata = .;
  }> SRAM AT> FLASH


  .bss :
  {
    _sbss = .;
	    __bss_start__ = _sbss;
	    *(.bss)
	    *(.bss.*)
	    *(COMMON)
	    . = ALIGN(4);
	    _ebss = .;
	    *(COMMON)
	    . = ALIGN(4);
	    _ebss = .;
	    __bss_end__ = _ebss;
	    . = ALIGN(4); 
	    end = .;
	    __end__ = .;
  }> SRAM

}