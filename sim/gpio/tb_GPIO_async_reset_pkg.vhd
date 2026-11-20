-------------------------------------------------------------------------------
-- Title      : tb_GPIO_async_reset_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_async_reset_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario async_reset of tb_GPIO, from reset :
--              Reset asserted between two clock edges : the output register
--              and data_oe are reset at once (asynchronous reset); the pins
--              stay high during the reset and are read after it
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.GPIO_csr_pkg.all;

library work;
use     work.tb_GPIO_bfm_pkg.all;

package tb_GPIO_async_reset_pkg is

  -- Reset asserted between two clock edges : the output register and data_oe
  -- are reset at once (asynchronous reset); the pins stay high during the
  -- reset and are read after it
  procedure run
    (constant oe_init  : in    byte_t           -- DATA_OE_INIT
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic        -- arst_b_i
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    );

end package tb_GPIO_async_reset_pkg;

package body tb_GPIO_async_reset_pkg is

  procedure run
    (constant oe_init  : in    byte_t           -- DATA_OE_INIT
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic        -- arst_b_i
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    ) is
  begin
    wr(GPIO_DATA_OUT, x"A5"       , "Write data_out", clk, sbi_if);
    wr(GPIO_DATA_OE , not oe_init , "Invert the reset direction", clk, sbi_if);
    set_pins(x"FF", clk, pins);
    wait for C_CLK_PERIOD/4;
    arst_b <= '0';
    wait for 1 ns;
    chk_pins(data_o , x"00"  , "data_o : reset without clock edge");
    chk_pins(data_oe, oe_init, "data_oe_o : DATA_OE_INIT without clock edge");
    wait until falling_edge(clk);
    arst_b <= '1';
    settle(clk);
    chk(GPIO_DATA_OUT, x"00"  , "data_out after the reset"                 , clk, sbi_if);
    chk(GPIO_DATA_OE , oe_init, "data_oe after the reset (DATA_OE_INIT)"   , clk, sbi_if);
    chk(GPIO_DATA_IN , x"FF"  , "data_in : pins held high during the reset", clk, sbi_if);
  end procedure;

end package body tb_GPIO_async_reset_pkg;
