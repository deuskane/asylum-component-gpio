-------------------------------------------------------------------------------
-- Title      : tb_GPIO_tests_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_tests_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenarios of tb_GPIO : names (valid items of TESTS_LIST) and
--              dispatch (run_test) to the package of each scenario
--              (tb_GPIO_<name>_pkg)
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

package tb_GPIO_tests_pkg is

  -- Names of the scenarios (valid items of TESTS_LIST)
  constant C_TESTS : string := "reset_values,output,input,mixed,async_reset,walking_one";

  -- Run the scenario name
  procedure run_test
    (constant name     : in    string
    ;constant oe_init  : in    byte_t           -- DATA_OE_INIT
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector -- data_oe_o
    ;signal   it       : in    std_logic        -- it_o
    );

end package tb_GPIO_tests_pkg;

package body tb_GPIO_tests_pkg is

  procedure run_test
    (constant name     : in    string
    ;constant oe_init  : in    byte_t
    ;signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector
    ;signal   data_o   : in    std_logic_vector
    ;signal   data_oe  : in    std_logic_vector
    ;signal   it       : in    std_logic
    ) is
  begin
    if    string_eq(name, "reset_values")
    then
      work.tb_GPIO_reset_values_pkg.run(oe_init, clk, sbi_if, pins, data_o, data_oe, it);
    elsif string_eq(name, "output")
    then
      work.tb_GPIO_output_pkg.run(clk, sbi_if, pins, data_o, data_oe);
    elsif string_eq(name, "input")
    then
      work.tb_GPIO_input_pkg.run(clk, sbi_if, pins, data_o, data_oe);
    elsif string_eq(name, "mixed")
    then
      work.tb_GPIO_mixed_pkg.run(clk, sbi_if, pins, data_o, data_oe);
    elsif string_eq(name, "async_reset")
    then
      work.tb_GPIO_async_reset_pkg.run(oe_init, clk, arst_b, sbi_if, pins, data_o, data_oe);
    elsif string_eq(name, "walking_one")
    then
      work.tb_GPIO_walking_one_pkg.run(clk, sbi_if, pins, data_o);
    else
      alert(TB_ERROR, "Unknown test " & name, C_TB_SCOPE);
    end if;
  end procedure;

end package body tb_GPIO_tests_pkg;
