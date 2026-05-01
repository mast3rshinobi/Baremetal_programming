# Bare Metal ARM Cortex M4 Programming

Understanding build procedure and linker script for bare metal embedded systems (ARM Cortex M4)

## Project Overview

This project demonstrates bare metal programming on ARM Cortex M4 microcontrollers, specifically targeting STM32 microcontrollers. It includes:

- **Linker Script** (`stm32_ls.ld`) - Defines memory layout and section placement
- **Main Application** (`main.c`) - GPIO LED blinking example
- **Build Configuration** - Complete embedded systems build workflow

## File Structure

### stm32_ls.ld - Linker Script

The linker script defines how your code and data are organized in memory:

```
MEMORY
├── SRAM (96KB) - RAM at 0x20000000
└── FLASH (512KB) - ROM at 0x8000000
```

**Key Sections:**

- **`.text`** - Program code and read-only data (stored in FLASH)
  - ISR vector table
  - Program instructions
  - Constant data (rodata)
  - Symbols: `_etext` (end of text section)

- **`.data`** - Initialized global/static variables
  - Loaded from FLASH, copied to SRAM at startup
  - Symbols: `_sdata` (start), `_edata` (end)

- **`.bss`** - Uninitialized global/static variables
  - Zeroed out at startup
  - Symbols: `_sbss`, `_ebss`, `__bss_start__`, `__bss_end__`

### main.c - GPIO LED Blink Application

Bare metal implementation of an LED blinking program on PA5:

**Hardware Setup:**
- LED connected to GPIO Port A, Pin 5 (PA5)
- Active high configuration

**Key Operations:**

1. **Enable Clock** - Enable GPIOA peripheral clock via RCC_AHB1ENR
2. **Configure Pin** - Set PA5 as digital output (GPIO_MODER)
3. **Toggle LED** - XOR GPIO_ODR register in infinite loop with delay

**Memory Addresses (STM32F4xx):**
- Peripheral Base: `0x40000000`
- AHB1 Peripherals: `0x40020000`
- RCC Base: `0x40023800`
- GPIOA Base: `0x40020000`

## Build Procedure

### Prerequisites

```bash
# ARM cross-compiler toolchain
arm-none-eabi-gcc
arm-none-eabi-ld
arm-none-eabi-objcopy
```

### Compilation Steps

```bash
# 1. Compile C code to object file
arm-none-eabi-gcc -c main.c -o main.o

# 2. Link object files using linker script
arm-none-eabi-ld -T stm32_ls.ld main.o -o firmware.elf

# 3. Generate binary for flashing
arm-none-eabi-objcopy -O binary firmware.elf firmware.bin

# Optional: Generate hex format
arm-none-eabi-objcopy -O ihex firmware.elf firmware.hex
```

### Flashing to Device

```bash
# Using ST-Link (STM32CubeProgrammer or OpenOCD)
st-flash write firmware.bin 0x8000000
```

## Linker Script Deep Dive

### Memory Definition

```ld
MEMORY
{
  SRAM (xrw) : ORIGIN = 0x20000000, LENGTH = 96K
  FLASH (rx) : ORIGIN = 0x8000000, LENGTH = 512K
}
```

- `xrw` - SRAM allows execute, read, write
- `rx` - FLASH allows read, execute (but not write)

### Section Placement

The `.data` section demonstrates LMA (Load Memory Address) vs VMA (Virtual Memory Address):

```ld
.data : { ... } > SRAM AT> FLASH
```

This means:
- Data is **placed in SRAM** at runtime (VMA)
- Data is **stored in FLASH** at compile-time (LMA)
- Startup code copies data from FLASH to SRAM

### Symbol Definitions

Linker symbols like `_etext`, `_sdata`, `_ebss` are used by startup code:

```c
extern unsigned int _sdata, _edata, _sbss, _ebss;

// Copy initialized data from FLASH to SRAM
for (unsigned int *src = &_la_data, *dst = &_sdata; dst < &_edata; ) {
    *dst++ = *src++;
}

// Zero out BSS section
for (unsigned int *ptr = &_sbss; ptr < &_ebss; ) {
    *ptr++ = 0;
}
```

## Key Concepts

### Peripheral Memory Mapping

Direct memory access to peripheral registers:

```c
#define GPIOA_ODR (*(volatile unsigned int*)(GPIOA_BASE + 0x14))
```

- `volatile` - Prevent compiler optimization on register access
- Pointer cast - Access memory-mapped I/O register

### Clock Enablement

Before using any peripheral, enable its clock:

```c
RCC_AHB1ENR |= RCC_AHB1ENR_GPIOA_EN;  // Enable GPIOA clock
```

### GPIO Configuration

Set PA5 as digital output:

```c
GPIOA_MODER &= ~(0x3 << (5 * 2));      // Clear bits [11:10]
GPIOA_MODER |= GPIO_MODER_PA5_OUTPUT;  // Set output mode
```

## Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Code doesn't run after flashing | ISR vector not at 0x8000000 | Check `.isr_vector` is first in `.text` |
| Variables not initialized | `.data` not copied at startup | Implement startup routine |
| Memory overflow | Section collision | Check linker map file (`.map`) |
| Peripheral not responding | Clock not enabled | Enable RCC clock before access |

## Resources

- [ARM Cortex M4 Generic User Guide](https://developer.arm.com/documentation/ddi0553/)
- [STM32F4 Reference Manual](https://www.st.com/resource/en/reference_manual/)
- [GNU Linker Script Guide](https://sourceware.org/binutils/docs/ld/)

## Next Steps

- Add startup code (SystemInit, data initialization)
- Implement vector table with interrupt handlers
- Add UART communication
- Implement timers and PWM
