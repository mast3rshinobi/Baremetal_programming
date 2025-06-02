#define PERIPH_BASE       0x40000000U
#define AHB1PERIPH_OFFSET 0x00020000U
#define AHB1PERIPH_BASE   (PERIPH_BASE + AHB1PERIPH_OFFSET)
#define GPIOA_BASE        (AHB1PERIPH_BASE + 0x0000)
#define RCC_BASE          (AHB1PERIPH_BASE + 0x3800)

#define RCC_AHB1ENR       (*(volatile unsigned int*)(RCC_BASE + 0x30))
#define GPIOA_MODER       (*(volatile unsigned int*)(GPIOA_BASE + 0x00))
#define GPIOA_ODR         (*(volatile unsigned int*)(GPIOA_BASE + 0x14))

#define RCC_AHB1ENR_GPIOA_EN (1 << 0)
#define GPIO_MODER_PA5_OUTPUT (1 << (5 * 2))

void delay(volatile unsigned int time) {
    while (time--) {
        for (volatile int i = 0; i < 1000; ++i);
    }
}

int main(void) {
    // Enable GPIOA clock
    RCC_AHB1ENR |= RCC_AHB1ENR_GPIOA_EN;

    // Set PA5 as output
    GPIOA_MODER &= ~(0x3 << (5 * 2));         // Clear mode bits
    GPIOA_MODER |= GPIO_MODER_PA5_OUTPUT;     // Set as output

    while (1) {
        GPIOA_ODR ^= (1 << 5); // Toggle PA5
        delay(1000);
    }

    return 0;
}




