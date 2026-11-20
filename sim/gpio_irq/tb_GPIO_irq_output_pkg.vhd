-------------------------------------------------------------------------------
-- Title      : tb_GPIO_irq_output_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_irq_output_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario output of tb_GPIO_irq, from reset :
--              A data write sets the output register of every line, also of
--              an input line (its value is driven once the line becomes
--              output), data reads the output register of the output lines
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

package tb_GPIO_irq_output_pkg is

  -- A data write sets the output register of every line, also of an input line
  -- (its value is driven once the line becomes output), data reads the output
  -- register of the output lines
  procedure run
    (constant nb_io    : in    natural          -- NB_IO
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    );

end package tb_GPIO_irq_output_pkg;

package body tb_GPIO_irq_output_pkg is

  procedure run
    (constant nb_io    : in    natural          -- NB_IO
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    ) is
  begin
    wr(GPIO_IRQ_DATA_OE, x"00", "Every line input", clk, sbi_if);
    wr(GPIO_IRQ_DATA   , x"5A", "Write data while every line is input", clk, sbi_if);
    wait until falling_edge(clk);
    chk_pins(data_o , x"5A", "data_o : output register written while the lines are input");
    chk_pins(data_oe, x"00", "data_oe_o : every line input");
    set_pins(x"A5", clk, pins);
    settle(clk);
    chk(GPIO_IRQ_DATA   , x"A5" and lines(nb_io), "data : pins of the input lines", clk, sbi_if);
    wr(GPIO_IRQ_DATA_OE, lines(nb_io), "Every line output", clk, sbi_if);
    wait until falling_edge(clk);
    chk_pins(data_oe, x"FF", "data_oe_o : every line output");
    chk_pins(data_o , x"5A", "data_o : value written before the direction");
    chk(GPIO_IRQ_DATA   , x"5A" and lines(nb_io), "data : output register of the output lines", clk, sbi_if);
    chk(GPIO_IRQ_DATA_OE, lines(nb_io)          , "data_oe"                                   , clk, sbi_if);
    wr(GPIO_IRQ_DATA   , x"C3", "Write data", clk, sbi_if);
    wait until falling_edge(clk);
    chk_pins(data_o , x"C3", "data_o : value written in data");
    chk(GPIO_IRQ_DATA   , x"C3" and lines(nb_io), "data : output register of the output lines", clk, sbi_if);
  end procedure;

end package body tb_GPIO_irq_output_pkg;
