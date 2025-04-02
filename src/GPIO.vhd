-------------------------------------------------------------------------------
-- Title      : GPIO
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : GPIO.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2013-12-26
-- Last update: 2025-04-02
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- It's a GPIO component
-- Register Map :
-- [0] Read/Write : data    (with data_oe mask apply)
-- [1] Read/Write : data_oe (if data_oe_force = 0)
-- [2] Read       : data_in
-- [3] Read/Write : data_out
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2025-03-05  0.6      mrosiere use csr from regtool
-- 2022-07-11  0.5      mrosiere DATA_OE_<INIT/FORCE> in NB_IO
-- 2018-06-01  0.4      mrosiere Add to address for a direct access at data_in_r
--                               and data_out_r
-- 2014-06-05  0.3      mrosiere Extract bus in another IP
-- 2014-02-07  0.2      mrosiere bus_read_data : protection during a reset
-- 2013-12-26  0.1      mrosiere Created
-------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.numeric_std.ALL;
library work;
use     work.GPIO_csr_pkg.ALL;
library work;
use     work.pbi_pkg.all;

entity GPIO is
  generic(
    NB_IO            : natural:=8;       -- Number of IO. Must be <= SIZE_DATA
    DATA_OE_INIT     : std_logic_vector; -- Direction of the IO after a reset
    DATA_OE_FORCE    : std_logic_vector; -- Can change the direction of the IO
    IT_ENABLE        : boolean:=false    -- GPIO can generate interruption
    );
  port   (
    clk_i            : in    std_logic;
    cke_i            : in    std_logic;
    arstn_i          : in    std_logic; -- asynchronous reset

    -- To IP
    pbi_ini_i        : in    pbi_ini_t;
    pbi_tgt_o        : out   pbi_tgt_t;

    -- To/From IO
    data_i           : in    std_logic_vector (NB_IO-1     downto 0);
    data_o           : out   std_logic_vector (NB_IO-1     downto 0);
    data_oe_o        : out   std_logic_vector (NB_IO-1     downto 0);
    
    -- To/From IT Ctrl
    interrupt_o      : out   std_logic;
    interrupt_ack_i  : in    std_logic;

    sw2hw_i          : in    GPIO_sw2hw_t;
    hw2sw_o          : out   GPIO_hw2sw_t

    );
end GPIO;

architecture rtl of GPIO is

  -----------------------------------------------------------------------------
  -- Local parameters
  -----------------------------------------------------------------------------
  
  -----------------------------------------------------------------------------
  -- Address
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Register
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Signal
  -----------------------------------------------------------------------------
  
begin

  -----------------------------------------------------------------------------
  -- Data I/O
  -----------------------------------------------------------------------------
  data_o                <= sw2hw_i.data_out.value(data_o   'range);
  data_oe_o             <= sw2hw_i.data_oe .value(data_oe_o'range);

  hw2sw_o.data.value    <= ((sw2hw_i.data_out.value and     sw2hw_i.data_oe .value) or
                            (sw2hw_i.data_in .value and not sw2hw_i.data_oe .value));
  hw2sw_o.data.we       <= '1';

  hw2sw_o.data_in.value <= std_logic_vector(resize(unsigned(data_i), hw2sw_o.data_in.value'length));
  hw2sw_o.data_in.we    <= '1';

  -----------------------------------------------------------------------------
  -- IP Output
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Interrupt
  -----------------------------------------------------------------------------
  interrupt_o <= '0';
end rtl;
