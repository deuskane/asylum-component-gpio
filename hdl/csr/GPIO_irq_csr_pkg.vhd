-- Generated VHDL Package for GPIO_irq

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

library asylum;
use     asylum.sbi_pkg.all;
--==================================
-- Module      : GPIO_irq
-- Description : CSR for General Purpose I/O
-- Width       : 8
--==================================

package GPIO_irq_csr_pkg is

  ------------------------------------
  -- Global Constants
  ------------------------------------

  constant GPIO_irq_ADDR_WIDTH : natural := 2;
  constant GPIO_irq_DATA_WIDTH : natural := 8;

  --==================================
  -- Register    : isr
  -- Description : Interruption Status Register
  -- Address     : 0x0
  -- Width       : 1
  -- Sw Access   : rw1c
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
  constant GPIO_irq_ISR : unsigned(GPIO_irq_ADDR_WIDTH-1 downto 0) := to_unsigned(0, GPIO_irq_ADDR_WIDTH);

  type GPIO_irq_isr_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : 0: interrupt is inactive, 1: interrupt is active
  -- Width       : 1
  --==================================
    value : std_logic_vector(1-1 downto 0);
  end record GPIO_irq_isr_sw2hw_t;

  type GPIO_irq_isr_hw2sw_t is record
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : 0: interrupt is inactive, 1: interrupt is active
  -- Width       : 1
  --==================================
    value : std_logic_vector(1-1 downto 0);
  end record GPIO_irq_isr_hw2sw_t;

  --==================================
  -- Register    : imr
  -- Description : Interruption Mask Register
  -- Address     : 0x1
  -- Width       : 1
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  constant GPIO_irq_IMR : unsigned(GPIO_irq_ADDR_WIDTH-1 downto 0) := to_unsigned(1, GPIO_irq_ADDR_WIDTH);

  type GPIO_irq_imr_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : enable
  -- Description : 0: interrupt is disable, 1: interrupt is enable
  -- Width       : 1
  --==================================
    enable : std_logic_vector(1-1 downto 0);
  end record GPIO_irq_imr_sw2hw_t;

  --==================================
  -- Register    : data
  -- Description : data
  -- Address     : 0x2
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
  constant GPIO_irq_DATA : unsigned(GPIO_irq_ADDR_WIDTH-1 downto 0) := to_unsigned(2, GPIO_irq_ADDR_WIDTH);

  type GPIO_irq_data_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : Data with data_oe with mask apply
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record GPIO_irq_data_sw2hw_t;

  type GPIO_irq_data_hw2sw_t is record
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : Data with data_oe with mask apply
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record GPIO_irq_data_hw2sw_t;

  --==================================
  -- Register    : data_oe
  -- Description : GPIO Direction
  -- Address     : 0x3
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  constant GPIO_irq_DATA_OE : unsigned(GPIO_irq_ADDR_WIDTH-1 downto 0) := to_unsigned(3, GPIO_irq_ADDR_WIDTH);

  type GPIO_irq_data_oe_sw2hw_t is record
    re : std_logic;
    we : std_logic;
  --==================================
  -- Field       : value
  -- Description : GPIO Direction : 0 input, 1 output
  -- Width       : 8
  --==================================
    value : std_logic_vector(8-1 downto 0);
  end record GPIO_irq_data_oe_sw2hw_t;

  ------------------------------------
  -- Structure GPIO_irq_t
  ------------------------------------
  type GPIO_irq_sw2hw_t is record
    isr : GPIO_irq_isr_sw2hw_t;
    imr : GPIO_irq_imr_sw2hw_t;
    data : GPIO_irq_data_sw2hw_t;
    data_oe : GPIO_irq_data_oe_sw2hw_t;
  end record GPIO_irq_sw2hw_t;

  type GPIO_irq_hw2sw_t is record
    isr : GPIO_irq_isr_hw2sw_t;
    data : GPIO_irq_data_hw2sw_t;
  end record GPIO_irq_hw2sw_t;

  ------------------------------------
  -- Component
  ------------------------------------
component GPIO_irq_registers is
  generic (
    MODULE_NAME :  string := "" -- Name of the module
   ;DATA_OE_INIT : std_logic_vector -- Direction of the IO after a reset
  );
  port (
    -- Clock and Reset
    clk_i      : in  std_logic
   ;arst_b_i   : in  std_logic
    -- Bus
   ;sbi_ini_i  : in  sbi_ini_t
   ;sbi_tgt_o  : out sbi_tgt_t
    -- CSR
   ;sw2hw_o    : out GPIO_irq_sw2hw_t
   ;hw2sw_i    : in  GPIO_irq_hw2sw_t
  );
end component GPIO_irq_registers;


end package GPIO_irq_csr_pkg;
