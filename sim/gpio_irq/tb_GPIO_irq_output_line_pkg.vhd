-------------------------------------------------------------------------------
-- Title      : tb_GPIO_irq_output_line_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_irq_output_line_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario output_line of tb_GPIO_irq, from reset :
--              No interrupt on a line configured as output (its pin is the
--              loopback of the driven value), nor when it becomes input
--              with its pin high, an interrupt again on an edge of the
--              input line; line : the lowest line with both edges, else the
--              lowest line of IRQ_POSEDGE
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

package tb_GPIO_irq_output_line_pkg is

  -- No interrupt on a line configured as output (its pin is the loopback of
  -- the driven value), nor when it becomes input with its pin high, an
  -- interrupt again on an edge of the input line; line : the lowest line with
  -- both edges, else the lowest line of IRQ_POSEDGE
  procedure run
    (constant line     : in    byte_t           -- one-hot
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   it       : in    std_logic        -- it_o
    );

end package tb_GPIO_irq_output_line_pkg;

package body tb_GPIO_irq_output_line_pkg is

  procedure run
    (constant line     : in    byte_t           -- one-hot
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   it       : in    std_logic        -- it_o
    ) is
  begin
    wr(GPIO_IRQ_IMR    , line  , "Unmask the line", clk, sbi_if);
    wr(GPIO_IRQ_DATA   , line  , "Output value 1", clk, sbi_if);
    wr(GPIO_IRQ_DATA_OE, line  , "The line is output", clk, sbi_if);
    set_pins(line, clk, pins);
    settle(clk);
    chk_it(it, '0', "it_o : no interrupt on a rising edge of an output line");
    chk(GPIO_IRQ_ISR, x"00", "isr : no rising edge on an output line", clk, sbi_if);
    set_pins(x"00", clk, pins);
    settle(clk);
    chk(GPIO_IRQ_ISR, x"00", "isr : no falling edge on an output line", clk, sbi_if);
    set_pins(line, clk, pins);
    settle(clk);
    wr(GPIO_IRQ_DATA_OE, x"00", "The line is input, its pin is high", clk, sbi_if);
    settle(clk);
    chk(GPIO_IRQ_ISR, x"00", "isr : no edge when the line becomes input", clk, sbi_if);
    set_pins(x"00", clk, pins);
    settle(clk);
    wr (GPIO_IRQ_ISR, x"FF", "Clear the falling edge, if any", clk, sbi_if);
    set_pins(line, clk, pins);
    settle(clk);
    chk_it(it, '1', "it_o : rising edge of an input line");
    chk(GPIO_IRQ_ISR, line, "isr : rising edge of an input line", clk, sbi_if);
    wr (GPIO_IRQ_ISR, line, "Clear the pending line", clk, sbi_if);
    chk(GPIO_IRQ_ISR, x"00", "isr cleared", clk, sbi_if);
  end procedure;

end package body tb_GPIO_irq_output_line_pkg;
