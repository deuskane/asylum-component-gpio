-------------------------------------------------------------------------------
-- Title      : tb_GPIO_input_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_input_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario input of tb_GPIO, from reset :
--              Every line input : data and data_in read the pins, data_oe_o
--              is 0, data_o keeps the output register
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

package tb_GPIO_input_pkg is

  -- Every line input : data and data_in read the pins, data_oe_o is 0, data_o
  -- keeps the output register
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    );

end package tb_GPIO_input_pkg;

package body tb_GPIO_input_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    ) is
  begin
    wr(GPIO_DATA_OUT, x"21", "Write data_out", clk, sbi_if);
    wr(GPIO_DATA_OE , x"00", "Every line input", clk, sbi_if);
    set_pins(x"3C", clk, pins);
    settle(clk);
    chk_pins(data_oe, x"00", "data_oe_o : every line input");
    chk_pins(data_o , x"21", "data_o : output register kept (pads disabled)");
    chk(GPIO_DATA    , x"3C", "data : pins of the input lines", clk, sbi_if);
    chk(GPIO_DATA_OE , x"00", "data_oe"                       , clk, sbi_if);
    chk(GPIO_DATA_IN , x"3C", "data_in : pins"                , clk, sbi_if);
    chk(GPIO_DATA_OUT, x"21", "data_out"                      , clk, sbi_if);
    set_pins(x"C3", clk, pins);
    settle(clk);
    chk(GPIO_DATA    , x"C3", "data : pins of the input lines", clk, sbi_if);
    chk(GPIO_DATA_IN , x"C3", "data_in : pins"                , clk, sbi_if);
  end procedure;

end package body tb_GPIO_input_pkg;
