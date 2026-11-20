-------------------------------------------------------------------------------
-- Title      : tb_GPIO_irq_tests_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_irq_tests_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenarios of tb_GPIO_irq : names (valid items of TESTS_LIST),
--              applicability to the generics and dispatch (run_test) to the
--              package of each scenario (tb_GPIO_irq_<name>_pkg)
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
use     asylum.string_pkg.all;

library work;
use     work.tb_GPIO_bfm_pkg.all;

package tb_GPIO_irq_tests_pkg is

  -- Names of the scenarios (valid items of TESTS_LIST)
  constant C_TESTS : string := "reset_values,output,input,posedge,negedge,mask,output_line,async_reset";

  -- mask and output_line need a line with a rising edge interrupt
  function test_applies
    (constant name     : in    string
    ;constant nb_io    : in    natural
    ;constant posedge  : in    byte_t
    ) return boolean;

  -- Run the scenario name
  procedure run_test
    (constant name     : in    string
    ;constant nb_io    : in    natural          -- NB_IO
    ;constant oe_init  : in    byte_t           -- DATA_OE_INIT
    ;constant posedge  : in    byte_t           -- IRQ_POSEDGE
    ;constant negedge  : in    byte_t           -- IRQ_NEGEDGE
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    ;signal   it       : in    std_logic        -- it_o
    );

end package tb_GPIO_irq_tests_pkg;

package body tb_GPIO_irq_tests_pkg is

  function test_applies
    (constant name     : in    string
    ;constant nb_io    : in    natural
    ;constant posedge  : in    byte_t
    ) return boolean is
  begin
    if string_eq(name, "mask") or string_eq(name, "output_line")
    then
      return (posedge and lines(nb_io)) /= x"00";
    end if;
    return true;
  end function;

  procedure run_test
    (constant name     : in    string
    ;constant nb_io    : in    natural
    ;constant oe_init  : in    byte_t
    ;constant posedge  : in    byte_t
    ;constant negedge  : in    byte_t
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector
    ;signal   it       : in    std_logic
    ) is
    variable v_line    : byte_t;
  begin
    if    string_eq(name, "reset_values")
    then
      work.tb_GPIO_irq_reset_values_pkg.run(nb_io, oe_init, clk, sbi_if, pins, data_o, data_oe, it);
    elsif string_eq(name, "output")
    then
      work.tb_GPIO_irq_output_pkg.run(nb_io, clk, sbi_if, pins, data_o, data_oe);
    elsif string_eq(name, "input")
    then
      work.tb_GPIO_irq_input_pkg.run(nb_io, clk, sbi_if, pins, data_o, data_oe);
    elsif string_eq(name, "posedge")
    then
      work.tb_GPIO_irq_posedge_pkg.run(nb_io, posedge, clk, sbi_if, pins, it);
    elsif string_eq(name, "negedge")
    then
      work.tb_GPIO_irq_negedge_pkg.run(nb_io, negedge, clk, sbi_if, pins, it);
    elsif string_eq(name, "mask")
    then
      work.tb_GPIO_irq_mask_pkg.run(posedge and lines(nb_io), clk, sbi_if, pins, it);
    elsif string_eq(name, "output_line")
    then
      -- The lowest line with both edges, else the lowest line of IRQ_POSEDGE
      v_line := lowest(posedge and negedge and lines(nb_io));
      if v_line = x"00"
      then
        v_line := lowest(posedge and lines(nb_io));
      end if;
      work.tb_GPIO_irq_output_line_pkg.run(v_line, clk, sbi_if, pins, it);
    elsif string_eq(name, "async_reset")
    then
      work.tb_GPIO_irq_async_reset_pkg.run(nb_io, oe_init, clk, arst_b, sbi_if, pins, data_o, data_oe, it);
    else
      alert(TB_ERROR, "Unknown test " & name, C_TB_SCOPE);
    end if;
  end procedure;

end package body tb_GPIO_irq_tests_pkg;
