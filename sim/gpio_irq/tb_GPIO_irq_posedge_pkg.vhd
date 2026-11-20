-------------------------------------------------------------------------------
-- Title      : tb_GPIO_irq_posedge_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_irq_posedge_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario posedge of tb_GPIO_irq, from reset :
--              Rising edge on every input line : the ISR records the lines
--              of IRQ_POSEDGE only, it_o latency, ISR write 0 has no effect
--              and write 1 clears (rw1c)
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

package tb_GPIO_irq_posedge_pkg is

  -- Rising edge on every input line : the ISR records the lines of IRQ_POSEDGE
  -- only, it_o latency, ISR write 0 has no effect and write 1 clears (rw1c)
  procedure run
    (constant nb_io    : in    natural          -- NB_IO
    ;constant posedge  : in    byte_t           -- IRQ_POSEDGE
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   it       : in    std_logic        -- it_o
    );

end package tb_GPIO_irq_posedge_pkg;

package body tb_GPIO_irq_posedge_pkg is

  procedure run
    (constant nb_io    : in    natural          -- NB_IO
    ;constant posedge  : in    byte_t           -- IRQ_POSEDGE
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   it       : in    std_logic        -- it_o
    ) is
    variable v_exp     : byte_t;
    variable v_cnt     : natural;
  begin
    v_exp := posedge and lines(nb_io);
    wr(GPIO_IRQ_DATA_OE, x"00", "Every line input", clk, sbi_if);
    wr(GPIO_IRQ_IMR    , x"FF", "Unmask every line", clk, sbi_if);
    set_pins(x"FF", clk, pins);
    it_latency(it, 10, v_cnt, clk);
    if v_exp /= x"00"
    then
      chk_int(v_cnt, C_IT_LATENCY, "it_o rises C_IT_LATENCY cycles after the rising edge of the pins");
    else
      chk_it(it, '0', "it_o : no rising edge interrupt (IRQ_POSEDGE = 0)");
    end if;
    settle(clk);
    chk(GPIO_IRQ_ISR, v_exp, "isr : rising edges of the IRQ_POSEDGE lines", clk, sbi_if);
    chk_it(it, or v_exp, "it_o = OR(isr and imr)");
    wr (GPIO_IRQ_ISR, x"00", "Write 0x00 : no effect", clk, sbi_if);
    chk(GPIO_IRQ_ISR, v_exp, "isr unchanged", clk, sbi_if);
    wr (GPIO_IRQ_ISR, lowest(v_exp), "Write 1 on the lowest pending line", clk, sbi_if);
    chk(GPIO_IRQ_ISR, v_exp and not lowest(v_exp), "Only that bit is cleared", clk, sbi_if);
    wr (GPIO_IRQ_ISR, x"FF", "Write 0xFF : clear every bit", clk, sbi_if);
    chk(GPIO_IRQ_ISR, x"00", "isr cleared", clk, sbi_if);
    wait until falling_edge(clk);
    chk_it(it, '0', "it_o = 0 once isr is cleared");
  end procedure;

end package body tb_GPIO_irq_posedge_pkg;
