-------------------------------------------------------------------------------
-- Title      : tb_GPIO_output_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_output_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario output of tb_GPIO, from reset :
--              Every line output : data_o follows the data and data_out
--              writes (data is an alias of data_out for a write), data and
--              data_out read the output register, data_in reads the pins
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

package tb_GPIO_output_pkg is

  -- Every line output : data_o follows the data and data_out writes (data is
  -- an alias of data_out for a write), data and data_out read the output
  -- register, data_in reads the pins
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    );

end package tb_GPIO_output_pkg;

package body tb_GPIO_output_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    ) is
  begin
    wr(GPIO_DATA_OE, x"FF", "Every line output", clk, sbi_if);
    wait until falling_edge(clk);
    chk_pins(data_oe, x"FF", "data_oe_o : every line output");
    chk_pins(data_o , x"00", "data_o : data_out reset value");
    set_pins(x"A5", clk, pins);
    wr(GPIO_DATA, x"21", "Write data", clk, sbi_if);
    wait until falling_edge(clk);
    chk_pins(data_o , x"21", "data_o : value written in data");
    settle(clk);
    chk(GPIO_DATA    , x"21", "data : output register of the output lines", clk, sbi_if);
    chk(GPIO_DATA_OE , x"FF", "data_oe"                                   , clk, sbi_if);
    chk(GPIO_DATA_IN , x"A5", "data_in : pins, whatever the direction"    , clk, sbi_if);
    chk(GPIO_DATA_OUT, x"21", "data_out : written through data"           , clk, sbi_if);
    wr(GPIO_DATA_OUT, x"5A", "Write data_out", clk, sbi_if);
    wait until falling_edge(clk);
    chk_pins(data_o , x"5A", "data_o : value written in data_out");
    chk(GPIO_DATA    , x"5A", "data : output register of the output lines", clk, sbi_if);
    chk(GPIO_DATA_OUT, x"5A", "data_out"                                  , clk, sbi_if);
    wr(GPIO_DATA_IN , x"FF", "Write data_in (read only)", clk, sbi_if);
    wait until falling_edge(clk);
    chk_pins(data_o , x"5A", "data_o : a write of data_in has no effect");
    chk(GPIO_DATA_OUT, x"5A", "data_out : a write of data_in has no effect", clk, sbi_if);
    chk(GPIO_DATA_IN , x"A5", "data_in : pins"                             , clk, sbi_if);
  end procedure;

end package body tb_GPIO_output_pkg;
