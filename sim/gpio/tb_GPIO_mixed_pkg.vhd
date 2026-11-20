-------------------------------------------------------------------------------
-- Title      : tb_GPIO_mixed_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_mixed_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario mixed of tb_GPIO, from reset :
--              Inputs and outputs on the same port : data reads the output
--              register on the output lines and the pins on the input
--              lines, per bit
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

package tb_GPIO_mixed_pkg is

  -- Inputs and outputs on the same port : data reads the output register on
  -- the output lines and the pins on the input lines, per bit
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    );

end package tb_GPIO_mixed_pkg;

package body tb_GPIO_mixed_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    ) is
  begin
    wr(GPIO_DATA_OUT, x"A5", "Write data_out", clk, sbi_if);
    wr(GPIO_DATA_OE , x"0F", "Lines 0 to 3 output, 4 to 7 input", clk, sbi_if);
    set_pins(x"3C", clk, pins);
    settle(clk);
    chk_pins(data_oe, x"0F", "data_oe_o : lines 0 to 3 output");
    chk_pins(data_o , x"A5", "data_o : output register");
    chk(GPIO_DATA   , x"35", "data : data_out(3:0), pins(7:4)", clk, sbi_if);
    chk(GPIO_DATA_IN, x"3C", "data_in : pins"                 , clk, sbi_if);
    wr(GPIO_DATA_OE , x"F0", "Lines 4 to 7 output, 0 to 3 input", clk, sbi_if);
    wait until falling_edge(clk);
    chk_pins(data_oe, x"F0", "data_oe_o : lines 4 to 7 output");
    chk(GPIO_DATA   , x"AC", "data : pins(3:0), data_out(7:4)", clk, sbi_if);
  end procedure;

end package body tb_GPIO_mixed_pkg;
