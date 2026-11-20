-------------------------------------------------------------------------------
-- Title      : tb_GPIO_walking_one_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_walking_one_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Scenario walking_one of tb_GPIO, from reset :
--              A walking one on the output register (every line output)
--              then on the pins (every line input), the stimulus of the
--              former tb_GPIO_vs_v1 (the GPIO_v1 comparison runs in every
--              scenario)
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

package tb_GPIO_walking_one_pkg is

  -- A walking one on the output register (every line output) then on the pins
  -- (every line input), the stimulus of the former tb_GPIO_vs_v1 (the GPIO_v1
  -- comparison runs in every scenario)
  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    );

end package tb_GPIO_walking_one_pkg;

package body tb_GPIO_walking_one_pkg is

  procedure run
    (signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ;signal   pins     : out   std_logic_vector -- data_i
    ;signal   data_o   : in    std_logic_vector
    ) is
    variable v_one     : byte_t;
  begin
    wr(GPIO_DATA_OE, x"FF", "Every line output", clk, sbi_if);
    for i in 0 to 8-1 loop
      v_one    := (others => '0');
      v_one(i) := '1';
      wr(GPIO_DATA, v_one, "Write data, line " & to_string(i), clk, sbi_if);
      wait until falling_edge(clk);
      chk_pins(data_o, v_one, "data_o : walking one, line " & to_string(i));
      chk(GPIO_DATA, v_one, "data : walking one, line " & to_string(i), clk, sbi_if);
    end loop;
    wr(GPIO_DATA_OE, x"00", "Every line input", clk, sbi_if);
    for i in 0 to 8-1 loop
      v_one    := (others => '0');
      v_one(i) := '1';
      set_pins(v_one, clk, pins);
      settle(clk);
      chk(GPIO_DATA   , v_one, "data : walking one on the pins, line " & to_string(i), clk, sbi_if);
      chk(GPIO_DATA_IN, v_one, "data_in : walking one on the pins, line " & to_string(i), clk, sbi_if);
    end loop;
  end procedure;

end package body tb_GPIO_walking_one_pkg;
