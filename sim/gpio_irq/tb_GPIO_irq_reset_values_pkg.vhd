-------------------------------------------------------------------------------
-- Title      : tb_GPIO_irq_reset_values_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_irq_reset_values_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario reset_values of tb_GPIO_irq, from reset :
--              Reset values of isr, imr, data_oe (DATA_OE_INIT) and of the
--              pins, it_o is 0, then data reads the pins of the input lines
--              through the synchronizer
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

package tb_GPIO_irq_reset_values_pkg is

  -- Reset values of isr, imr, data_oe (DATA_OE_INIT) and of the pins, it_o is
  -- 0, then data reads the pins of the input lines through the synchronizer
  procedure run
    (constant nb_io    : in    natural          -- NB_IO
    ;constant oe_init  : in    byte_t           -- DATA_OE_INIT
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    ;signal   it       : in    std_logic        -- it_o
    );

end package tb_GPIO_irq_reset_values_pkg;

package body tb_GPIO_irq_reset_values_pkg is

  procedure run
    (constant nb_io    : in    natural          -- NB_IO
    ;constant oe_init  : in    byte_t           -- DATA_OE_INIT
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    ;signal   it       : in    std_logic        -- it_o
    ) is
  begin
    chk_pins(data_o , x"00"  , "data_o : output register reset value");
    chk_pins(data_oe, oe_init, "data_oe_o : DATA_OE_INIT");
    chk_it  (it     , '0'    , "it_o after reset");
    chk(GPIO_IRQ_ISR    , x"00"  , "Reset value isr"                    , clk, sbi_if);
    chk(GPIO_IRQ_IMR    , x"00"  , "Reset value imr"                    , clk, sbi_if);
    chk(GPIO_IRQ_DATA_OE, oe_init, "Reset value data_oe (DATA_OE_INIT)" , clk, sbi_if);
    chk(GPIO_IRQ_DATA   , x"00"  , "Reset value data (pins at 0)"       , clk, sbi_if);
    set_pins(x"A5", clk, pins);
    settle  (clk);
    chk(GPIO_IRQ_DATA   , x"A5" and lines(nb_io) and not oe_init, "data : pins of the input lines, output register (0) of the others", clk, sbi_if);
  end procedure;

end package body tb_GPIO_irq_reset_values_pkg;
