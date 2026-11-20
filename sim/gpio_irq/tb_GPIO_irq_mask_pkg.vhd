-------------------------------------------------------------------------------
-- Title      : tb_GPIO_irq_mask_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_irq_mask_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario mask of tb_GPIO_irq, from reset :
--              Imr only masks it_o : the edge of a masked line is recorded
--              in the ISR (polling), unmasking a pending line raises it_o,
--              masking it again drops it_o and keeps the ISR (needs a line
--              of IRQ_POSEDGE)
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

package tb_GPIO_irq_mask_pkg is

  -- Imr only masks it_o : the edge of a masked line is recorded in the ISR
  -- (polling), unmasking a pending line raises it_o, masking it again drops
  -- it_o and keeps the ISR (needs a line of IRQ_POSEDGE)
  procedure run
    (constant posedge  : in    byte_t           -- IRQ_POSEDGE
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   it       : in    std_logic        -- it_o
    );

end package tb_GPIO_irq_mask_pkg;

package body tb_GPIO_irq_mask_pkg is

  procedure run
    (constant posedge  : in    byte_t           -- IRQ_POSEDGE
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   it       : in    std_logic        -- it_o
    ) is
    variable v_line    : byte_t;
  begin
    v_line := lowest(posedge);
    wr(GPIO_IRQ_DATA_OE, x"00", "Every line input, every line masked", clk, sbi_if);
    set_pins(v_line, clk, pins);
    settle(clk);
    chk_it(it, '0', "it_o : the line is masked");
    chk(GPIO_IRQ_ISR, v_line, "isr records the edge of a masked line", clk, sbi_if);
    wr(GPIO_IRQ_IMR, not v_line, "Unmask every other line", clk, sbi_if);
    chk(GPIO_IRQ_IMR, not v_line, "imr read back", clk, sbi_if);
    wait until falling_edge(clk);
    chk_it(it, '0', "it_o : the pending line is still masked");
    wr(GPIO_IRQ_IMR, v_line, "Unmask the pending line", clk, sbi_if);
    wait until falling_edge(clk);
    chk_it(it, '1', "it_o : pending line unmasked");
    wr(GPIO_IRQ_IMR, x"00", "Mask the pending line", clk, sbi_if);
    wait until falling_edge(clk);
    chk_it(it, '0', "it_o : pending line masked again");
    chk(GPIO_IRQ_ISR, v_line, "isr kept while masked", clk, sbi_if);
    wr (GPIO_IRQ_ISR, v_line, "Clear the pending line", clk, sbi_if);
    chk(GPIO_IRQ_ISR, x"00" , "isr cleared", clk, sbi_if);
  end procedure;

end package body tb_GPIO_irq_mask_pkg;
