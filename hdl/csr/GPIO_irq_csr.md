# GPIO_irq
CSR for General Purpose I/O

| Address | Registers |
|---------|-----------|
|0x0|isr|
|0x1|imr|
|0x2|data|
|0x3|data_out|

## 0x0 isr
Interruption Status Register

### [0:0] value
0: interrupt is inactive, 1: interrupt is active

## 0x1 imr
Interruption Mask Register

### [0:0] enable
0: interrupt is disable, 1: interrupt is enable

## 0x2 data
data

### [7:0] value
Data with data_oe with mask apply

## 0x3 data_out
GPIO Output

### [7:0] value
Output Data of GPIO

