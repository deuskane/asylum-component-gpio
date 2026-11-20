-------------------------------------------------------------------------------
-- Title      : tb_GPIO_irq_input_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_irq_input_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario input of tb_GPIO_irq, from reset :
--              Every line input then half of the lines : data reads the
--              pins of the input lines and the output register of the
--              output lines, per bit
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
use     asylum.GPIO_irq_csr_pkg.all;

library work;
use     work.tb_GPIO_bfm_pkg.all;

package tb_GPIO_irq_input_pkg is

  -- Every line input then half of the lines : data reads the pins of the input
  -- lines and the output register of the output lines, per bit
  procedure run
    (constant nb_io    : in    natural          -- NB_IO
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    );

end package tb_GPIO_irq_input_pkg;

package body tb_GPIO_irq_input_pkg is

  procedure run
    (constant nb_io    : in    natural          -- NB_IO
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    ) is
  begin
    wr(GPIO_IRQ_DATA   , x"0F", "Write data", clk, sbi_if);
    wr(GPIO_IRQ_DATA_OE, x"00", "Every line input", clk, sbi_if);
    set_pins(x"3C", clk, pins);
    settle(clk);
    chk_pins(data_oe, x"00", "data_oe_o : every line input");
    chk_pins(data_o , x"0F", "data_o : output register kept (pads disabled)");
    chk(GPIO_IRQ_DATA   , x"3C" and lines(nb_io), "data : pins of the input lines", clk, sbi_if);
    chk(GPIO_IRQ_DATA_OE, x"00"                 , "data_oe"                       , clk, sbi_if);
    wr(GPIO_IRQ_DATA_OE, x"55" and lines(nb_io), "Even lines output, odd lines input", clk, sbi_if);
    wait until falling_edge(clk);
    chk_pins(data_oe, x"55", "data_oe_o : even lines output");
    chk(GPIO_IRQ_DATA   , ((x"0F" and x"55") or (x"3C" and x"AA")) and lines(nb_io), "data : output register (even lines), pins (odd lines)", clk, sbi_if);
  end procedure;

end package body tb_GPIO_irq_input_pkg;
