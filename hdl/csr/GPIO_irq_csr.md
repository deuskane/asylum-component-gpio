# GPIO_irq
CSR for General Purpose I/O

| Address | Registers |
|---------|-----------|
|0x0|isr|
|0x1|imr|
|0x2|data|
|0x3|data_oe|

## 0x0 isr
Interruption Status Register

### [7:0] value
0: interrupt is inactive, 1: interrupt is active

## 0x1 imr
Interruption Mask Register

### [7:0] enable
0: interrupt is disable, 1: interrupt is enable

## 0x2 data
data (write the output value of a line before setting it as output)

### [7:0] value
Read : output value (output lines) or pin (input lines). Write : output register of every line

## 0x3 data_oe
GPIO Direction

### [7:0] value
GPIO Direction : 0 input, 1 output

