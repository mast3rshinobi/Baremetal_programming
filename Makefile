CC=arm-none-eabi-gcc
MACH=cortex-m4
CFLAGS= -c -mcpu=$(MACH) -mthumb -mfloat-abi=soft -std=gnu11 -Wall -O0
LDFLAGS= -mcpu=$(MACH) -mthumb -mfloat-abi=soft --specs=nano.specs --specs=nosys.specs -T stm32_ls.ld -Wl,-Map=final.map

all:main.o stm32_startup.o final.elf final.bin

main.o:main.c
	$(CC) $(CFLAGS) -o $@ $^

stm32_startup.o:stm32_startup.c
	$(CC) $(CFLAGS) -o $@ $^

final.elf: main.o stm32_startup.o
	$(CC) $(LDFLAGS) -o $@ $^

final.bin: final.elf
	arm-none-eabi-objcopy -O binary $^ $@
		
clean:
	rm -rf *.o *.elf *.map *.bin
