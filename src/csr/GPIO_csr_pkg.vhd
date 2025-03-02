-- Generated VHDL Package for GPIO

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

-- Module      : GPIO
-- Description : CSR for General Purpose I/O
-- Width       : 8

package GPIO_csr_pkg is

  --==================================
  -- Register    : data
  -- Description : data - with data_oe mask apply
  -- Address     : 0x0
  --==================================
  type GPIO_data_sw2hw_t is record
    re : std_logic;
    -- Field       : data.value
    -- Description : Data with data_oe with mask apply
    value : std_logic_vector(8-1 downto 0);
  end record GPIO_data_sw2hw_t;

  type GPIO_data_hw2sw_t is record
    we : std_logic;
    -- Field       : data.value
    -- Description : Data with data_oe with mask apply
    value : std_logic_vector(8-1 downto 0);
  end record GPIO_data_hw2sw_t;

  --==================================
  -- Register    : data_oe
  -- Description : GPIO Direction
  -- Address     : 0x1
  --==================================
  type GPIO_data_oe_sw2hw_t is record
    re : std_logic;
    we : std_logic;
    -- Field       : data_oe.value
    -- Description : GPIO Direction : 0 input, 1 output
    value : std_logic_vector(8-1 downto 0);
  end record GPIO_data_oe_sw2hw_t;

  --==================================
  -- Register    : data_in
  -- Description : GPIO Input
  -- Address     : 0x2
  --==================================
  type GPIO_data_in_sw2hw_t is record
    re : std_logic;
    -- Field       : data_in.value
    -- Description : Input Data of GPIO
    value : std_logic_vector(8-1 downto 0);
  end record GPIO_data_in_sw2hw_t;

  type GPIO_data_in_hw2sw_t is record
    we : std_logic;
    -- Field       : data_in.value
    -- Description : Input Data of GPIO
    value : std_logic_vector(8-1 downto 0);
  end record GPIO_data_in_hw2sw_t;

  --==================================
  -- Register    : data_out
  -- Description : GPIO Output
  -- Address     : 0x3
  --==================================
  type GPIO_data_out_sw2hw_t is record
    re : std_logic;
    we : std_logic;
    -- Field       : data_out.value
    -- Description : Output Data of GPIO
    value : std_logic_vector(8-1 downto 0);
  end record GPIO_data_out_sw2hw_t;

  ------------------------------------
  -- Structure {module}_t
  ------------------------------------
  type GPIO_sw2hw_t is record
    data : GPIO_data_sw2hw_t;
    data_oe : GPIO_data_oe_sw2hw_t;
    data_in : GPIO_data_in_sw2hw_t;
    data_out : GPIO_data_out_sw2hw_t;
  end record GPIO_sw2hw_t;

  type GPIO_hw2sw_t is record
    data : GPIO_data_hw2sw_t;
    data_in : GPIO_data_in_hw2sw_t;
  end record GPIO_hw2sw_t;
end package GPIO_csr_pkg;
