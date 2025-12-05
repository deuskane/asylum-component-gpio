# GPIO Component

## Table of Contents

- [Introduction](#introduction)
- [HDL Modules](#hdl-modules)
  - [GPIO](#gpio)
  - [GPIO_v1](#gpio_v1)
  - [sbi_GPIO](#sbi_gpio)
- [Register Map (CSR)](#register-map-csr)
- [Verification](#verification)

## Introduction

This repository contains the GPIO (General Purpose Input/Output) component as part of the Asylum project. The GPIO component provides a flexible and configurable interface for managing general-purpose digital I/O pins with support for:

- Configurable number of I/O pins (up to 8 or more)
- Programmable input/output direction per pin
- Register-based control and status via CSR (Control and Status Registers)
- Optional interrupt generation capability
- Support for multiple bus interfaces (PBI legacy, SBI modern)

The component is designed to be integrated into larger digital systems and provides both a low-level GPIO core with CSR integration (`GPIO` with `GPIO_registers`) and a bus-integrated wrapper (`sbi_GPIO`).

### Project Structure

```
hdl/                   # Hardware Description Language files
├── GPIO.vhd           # Main GPIO core module (CSR-based)
├── GPIO_v1.vhd        # Legacy GPIO implementation (PBI-based)
├── sbi_GPIO.vhd       # SBI bus interface wrapper
├── gpio_pkg.vhd       # Component package definitions
└── csr/               # Control and Status Register definitions
    ├── GPIO.hjson     # Register specification file
    ├── GPIO_csr.h     # Generated C header file
    ├── GPIO_csr.md    # Register documentation
    └── GPIO_csr.vhd   # Generated CSR VHDL package
sim/                   # Simulation and verification files
├── tb_GPIO_bidir.vhd  # Testbench for bidirectional I/O testing
GPIO.core              # FuseSoC core specification file
```

## HDL Modules

### GPIO

**File**: `hdl/GPIO.vhd`

The main GPIO core module that implements the fundamental GPIO functionality. This module directly interfaces with the CSR (Control and Status Register) system and provides I/O pin control.

#### Generics

| Generic | Type | Default | Description |
|---------|------|---------|-------------|
| `NB_IO` | natural | 8 | Number of I/O pins. Must be ≤ data width of the CSR system |
| `IT_ENABLE` | boolean | false | Enable interrupt generation capability |

#### Ports

| Port | Direction | Type | Width | Description |
|------|-----------|------|-------|-------------|
| `clk_i` | in | std_logic | 1 | System clock |
| `cke_i` | in | std_logic | 1 | Clock enable signal |
| `arstn_i` | in | std_logic | 1 | Asynchronous active-low reset |
| `data_i` | in | std_logic_vector | NB_IO | Input data from GPIO pins |
| `data_o` | out | std_logic_vector | NB_IO | Output data to GPIO pins |
| `data_oe_o` | out | std_logic_vector | NB_IO | Output enable control (1=output, 0=input) |
| `interrupt_o` | out | std_logic | 1 | Interrupt request signal |
| `interrupt_ack_i` | in | std_logic | 1 | Interrupt acknowledge signal |
| `sw2hw_i` | in | GPIO_sw2hw_t | - | Software-to-hardware register interface |
| `hw2sw_o` | out | GPIO_hw2sw_t | - | Hardware-to-software register interface |

#### Operation

The GPIO module operates as follows:

1. **Data Path**: The module multiplexes the internal output (`data_out`) and input (`data_in`) based on the direction register (`data_oe`)
   - When a pin is configured as output (data_oe[i]=1), the output driver controls the pin
   - When a pin is configured as input (data_oe[i]=0), the input is sampled

2. **Register Interface**: Communication with the CSR system via `sw2hw_i` and `hw2sw_o` interfaces
   - `sw2hw_i.data_out.value`: Output register value from software
   - `sw2hw_i.data_oe.value`: Direction register value from software
   - `hw2sw_o.data_in.value`: Feedback of actual pin states to software
   - `hw2sw_o.data.value`: Read-back of pin states with direction masking applied

3. **Interrupt Handling** (when IT_ENABLE=true): Can generate interrupts on GPIO state changes

### GPIO_v1

**File**: `hdl/GPIO_v1.vhd`

Legacy GPIO implementation that uses the older PBI (Processor Bus Interface) for register access. This module is maintained for backward compatibility.

#### Generics

| Generic | Type | Default | Description |
|---------|------|---------|-------------|
| `SIZE_ADDR` | natural | 2 | Bus address width in bits |
| `SIZE_DATA` | natural | 8 | Bus data width in bits |
| `NB_IO` | natural | 8 | Number of I/O pins. Must be ≤ SIZE_DATA |
| `DATA_OE_INIT` | std_logic_vector | - | Initial direction state after reset (0=input, 1=output) |
| `DATA_OE_FORCE` | std_logic_vector | - | Force direction bits (read-only direction pins) |
| `IT_ENABLE` | boolean | false | Enable interrupt generation capability |

#### Ports

| Port | Direction | Type | Width | Description |
|------|-----------|------|-------|-------------|
| `clk_i` | in | std_logic | 1 | System clock |
| `cke_i` | in | std_logic | 1 | Clock enable signal |
| `arstn_i` | in | std_logic | 1 | Asynchronous active-low reset |
| `cs_i` | in | std_logic | 1 | Chip select |
| `re_i` | in | std_logic | 1 | Read enable |
| `we_i` | in | std_logic | 1 | Write enable |
| `addr_i` | in | std_logic_vector | SIZE_ADDR | Register address |
| `wdata_i` | in | std_logic_vector | SIZE_DATA | Write data |
| `rdata_o` | out | std_logic_vector | SIZE_DATA | Read data |
| `busy_o` | out | std_logic | 1 | Bus busy signal |
| `data_i` | in | std_logic_vector | NB_IO | Input data from GPIO pins |
| `data_o` | out | std_logic_vector | NB_IO | Output data to GPIO pins |
| `data_oe_o` | out | std_logic_vector | NB_IO | Output enable control |
| `interrupt_o` | out | std_logic | 1 | Interrupt request signal |
| `interrupt_ack_i` | in | std_logic | 1 | Interrupt acknowledge signal |

#### Operation

GPIO_v1 provides a legacy register interface using direct address decoding:

1. **Register Map** (PBI-based):
   - Address 0x0: Data register (read: pin states with mask, write: output data)
   - Address 0x1: Direction register (read/write: I/O direction control)
   - Address 0x2: Data input (read-only: raw input data)
   - Address 0x3: Data output (read/write: output register)

2. **Bus Protocol**: Responds to PBI read/write transactions with chip select and address decoding

### sbi_GPIO

**File**: `hdl/sbi_GPIO.vhd`

Modern GPIO wrapper that provides SBI (Simple Bus Interface) abstraction. It instantiates both the CSR register controller and the GPIO core, connecting them together with the SBI bus.

#### Generics

| Generic | Type | Default | Description |
|---------|------|---------|-------------|
| `NB_IO` | natural | 8 | Number of I/O pins |
| `DATA_OE_INIT` | std_logic_vector | - | Initial direction state after reset |
| `IT_ENABLE` | boolean | false | Enable interrupt generation capability |

#### Ports

| Port | Direction | Type | Width | Description |
|------|-----------|------|-------|-------------|
| `clk_i` | in | std_logic | 1 | System clock |
| `cke_i` | in | std_logic | 1 | Clock enable signal |
| `arstn_i` | in | std_logic | 1 | Asynchronous active-low reset |
| `sbi_ini_i` | in | sbi_ini_t | - | SBI initiator interface (requests) |
| `sbi_tgt_o` | out | sbi_tgt_t | - | SBI target interface (responses) |
| `data_i` | in | std_logic_vector | NB_IO | Input data from GPIO pins |
| `data_o` | out | std_logic_vector | NB_IO | Output data to GPIO pins |
| `data_oe_o` | out | std_logic_vector | NB_IO | Output enable control |
| `interrupt_o` | out | std_logic | 1 | Interrupt request signal |
| `interrupt_ack_i` | in | std_logic | 1 | Interrupt acknowledge signal |

#### Operation

sbi_GPIO serves as the primary integration point for the GPIO component:

1. **Hierarchical Structure**:
   - Instantiates `GPIO_registers` (CSR controller) for register management
   - Instantiates `GPIO` (core) for I/O control
   - Bridges SBI bus protocol to internal register interface

2. **Data Flow**:
   - SBI bus transactions → GPIO_registers → sw2hw control signals
   - GPIO core hw2sw status signals → GPIO_registers → SBI read responses
   - GPIO core ↔ external I/O pins

## Register Map (CSR)

**Documentation**: [hdl/csr/GPIO_csr.md](hdl/csr/GPIO_csr.md)

**Specification**: `hdl/csr/GPIO.hjson`

The GPIO component exposes four 8-bit registers for software control and status monitoring. All registers are 8-bit wide and accessible via the SBI interface.

### Register Summary

| Address | Offset | Register | Access | Width | Description |
|---------|--------|----------|--------|-------|-------------|
| 0x0 | +0 | [data](#0x0-data) | R/W | 8 bits | Data with direction mask applied |
| 0x1 | +1 | [data_oe](#0x1-data_oe) | R/W | 8 bits | I/O Direction control |
| 0x2 | +2 | [data_in](#0x2-data_in) | R/O | 8 bits | GPIO Input values |
| 0x3 | +3 | [data_out](#0x3-data_out) | R/W | 8 bits | GPIO Output values |

### 0x0 data

**Description**: Data register - provides read-back with direction mask applied

**Access**: Read/Write

**Fields**:
- **[7:0] value**: Data with data_oe mask apply
  - Reading this register returns the GPIO pin states with the direction mask applied
  - For output pins (data_oe=1), returns the output data value
  - For input pins (data_oe=0), returns the input pin state

### 0x1 data_oe

**Description**: GPIO Direction control register

**Access**: Read/Write

**Initial Value**: `DATA_OE_INIT` parameter

**Fields**:
- **[7:0] value**: GPIO Direction
  - `0` = Input (pin is used as input)
  - `1` = Output (pin is used as output)
  - Each bit controls one GPIO pin independently

### 0x2 data_in

**Description**: GPIO Input register - raw input values from pins

**Access**: Read-Only

**Fields**:
- **[7:0] value**: Input Data of GPIO
  - Contains the direct sampled values from GPIO input pins
  - Always reflects the actual pin states regardless of direction settings

### 0x3 data_out

**Description**: GPIO Output register - output values to pins

**Access**: Read/Write

**Fields**:
- **[7:0] value**: Output Data of GPIO
  - Contains the values driven on GPIO pins configured as outputs
  - Bits corresponding to input pins (data_oe=0) have no effect on the pins

## Verification

The GPIO component includes comprehensive verification through simulation testbenches.

### Testbench Structure

**File**: `sim/tb_GPIO_bidir.vhd`

The `tb_GPIO_bidir` testbench provides functional verification of the GPIO component, particularly focusing on bidirectional I/O operation.

#### Test Coverage

The testbench validates:

1. **Direction Control**: 
   - Configuration of pins as inputs or outputs
   - Switching direction at runtime
   - Direction persistence across clock cycles

2. **Data I/O**:
   - Writing to output pins and verifying external data
   - Reading from input pins and verifying internal capture
   - Masking behavior based on direction settings

3. **Bidirectional Operation**:
   - Simultaneous input and output on different pins
   - Dynamic direction switching with data preservation
   - Pull-up/pull-down simulation

4. **Reset Behavior**:
   - Proper initialization on asynchronous reset
   - Direction register initialization with `DATA_OE_INIT`
   - Register state clearing

### Running Simulations

The component uses **GHDL** as the default simulation tool and is configured via FuseSoC.

#### Available Simulation Targets

**Default Target** (`default`):
- Synthesizes the design without simulation
- Uses the main GPIO module
- CSR code is auto-generated via the `regtool` generator

**Simulation Target** (`sim_testcase`):
- Runs the testbench with all test cases
- Generates VCD waveform file: `dut.vcd`
- Uses GHDL as the simulation engine

#### Simulation Command

```bash
fusesoc run --target=sim_testcase asylum:component:GPIO:1.6.2
```

This command will:
1. Generate CSR VHDL code from `hdl/csr/GPIO.hjson`
2. Compile all testbench and design files
3. Execute the simulation
4. Produce `dut.vcd` for waveform analysis

#### Waveform Analysis

Open the generated VCD file in a waveform viewer (e.g., GTKWave) to analyze:
- GPIO signal timing
- Register state transitions
- Bus transactions
- Interrupt signals (if IT_ENABLE=true)

### CSR Code Generation

The CSR registers are automatically generated from the specification file using the `regtool` generator:

**Generator Configuration** (from `GPIO.core`):
- **Input**: `hdl/csr/GPIO.hjson`
- **Output Directory**: `hdl/csr/`
- **Generated Files**:
  - `GPIO_csr.vhd` - VHDL CSR controller package
  - `GPIO_csr_pkg.vhd` - VHDL type definitions
  - `GPIO_csr.h` - C header file for software access
  - `GPIO_csr.md` - Register documentation

**Parameters**:
- `name`: GPIO
- `copy`: Copies generated files to `hdl/csr/`
- `logical_name`: asylum

### Project Configuration

**File**: `GPIO.core`

The project uses FuseSoC for build management. Key configuration:

- **Component Name**: `asylum:component:GPIO:1.6.2`
- **Default Tool**: GHDL (VHDL simulator)
- **Dependencies**:
  - `asylum:utils:generators` (for code generation)
  - `asylum:utils:pkg` (utility packages)
- **CSR Generator**: regtool (auto-generates register interfaces)

### Makefile

**File**: `Makefile`

Provides convenient targets for common tasks like simulation, synthesis, and cleanup.
