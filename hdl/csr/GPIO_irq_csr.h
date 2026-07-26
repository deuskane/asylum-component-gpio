#ifndef GPIO_IRQ_REGISTERS_H
#define GPIO_IRQ_REGISTERS_H

#include <stdint.h>

// Module      : GPIO_irq
// Description : CSR for General Purpose I/O
// Width       : 8

//==================================
// Register    : isr
// Description : Interruption Status Register
// Address     : 0x0
//==================================
#define GPIO_IRQ_ISR 0x0

// Field       : isr.value
// Description : 0: interrupt is inactive, 1: interrupt is active
// Range       : [0]
#define GPIO_IRQ_ISR_VALUE      0
#define GPIO_IRQ_ISR_VALUE_MASK 1

//==================================
// Register    : imr
// Description : Interruption Mask Register
// Address     : 0x1
//==================================
#define GPIO_IRQ_IMR 0x1

// Field       : imr.enable
// Description : 0: interrupt is disable, 1: interrupt is enable
// Range       : [0]
#define GPIO_IRQ_IMR_ENABLE      0
#define GPIO_IRQ_IMR_ENABLE_MASK 1

//==================================
// Register    : data
// Description : data
// Address     : 0x2
//==================================
#define GPIO_IRQ_DATA 0x2

// Field       : data.value
// Description : Data with data_oe with mask apply
// Range       : [7:0]
#define GPIO_IRQ_DATA_VALUE      0
#define GPIO_IRQ_DATA_VALUE_MASK 255

//==================================
// Register    : data_out
// Description : GPIO Output
// Address     : 0x3
//==================================
#define GPIO_IRQ_DATA_OUT 0x3

// Field       : data_out.value
// Description : Output Data of GPIO
// Range       : [7:0]
#define GPIO_IRQ_DATA_OUT_VALUE      0
#define GPIO_IRQ_DATA_OUT_VALUE_MASK 255

//----------------------------------
// Structure GPIO_irq_t
//----------------------------------
typedef struct {
  uint8_t isr; // 0x0
  uint8_t imr; // 0x1
  uint8_t data; // 0x2
  uint8_t data_out; // 0x3
} GPIO_irq_t;

#endif // GPIO_IRQ_REGISTERS_H
