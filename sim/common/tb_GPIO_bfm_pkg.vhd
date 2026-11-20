-------------------------------------------------------------------------------
-- Title      : tb_GPIO_bfm_pkg
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_bfm_pkg.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: Helpers of the tb_GPIO and tb_GPIO_irq scenarios : SBI
--              accesses (SBI VIP, zero wait state), checks, pins driven on
--              the falling edge of the clock, reset pulse.
--              Register values are 8-bit (CSR width), the pins are NB_IO-bit :
--              the helpers keep the NB_IO low bits of a value.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-11-20  1.0      mrosiere Created (helpers of tb_GPIO and tb_GPIO_irq)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

package tb_GPIO_bfm_pkg is

  constant C_TB_SCOPE    : string  := "TB_GPIO_BFM";
  constant C_CLK_PERIOD  : time    := 20 ns;
  constant C_SYNC_CYCLES : natural := 2;  -- Latency of the data_i synchronizer
  constant C_IT_LATENCY  : natural := 3;  -- Pin edge to it_o : synchronizer, ISR

  subtype  byte_t is std_logic_vector(8-1 downto 0);

  -- Zero wait state target : any cycle with ready = '0' is an error
  constant C_SBI_CFG     : t_sbi_bfm_config := (
    max_wait_cycles            => 0,
    max_wait_cycles_severity   => error,
    use_fixed_wait_cycles_read => false,
    fixed_wait_cycles_read     => 0,
    clock_period               => -1 ns,
    clock_period_margin        => 0 ns,
    clock_margin_severity      => TB_ERROR,
    setup_time                 => -1 ns,
    hold_time                  => -1 ns,
    bfm_sync                   => SYNC_ON_CLOCK_ONLY,
    match_strictness           => MATCH_EXACT,
    id_for_bfm                 => ID_BFM,
    id_for_bfm_wait            => ID_BFM_WAIT,
    id_for_bfm_poll            => ID_BFM_POLL,
    use_ready_signal           => true
  );

  -- Register value with the bits of the nb_io lines set
  function lines
    (constant nb_io    : in    natural
    ) return byte_t;

  -- One-hot value of the lowest bit set in v (0 if none)
  function lowest
    (constant v        : in    byte_t
    ) return byte_t;

  -- SBI write
  procedure wr
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- SBI read and check
  procedure chk
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    );

  -- Check of NB_IO pins (data_o, data_oe_o) : the NB_IO low bits of exp
  procedure chk_pins
    (signal   pins     : in    std_logic_vector
    ;constant exp      : in    byte_t
    ;constant msg      : in    string
    );

  -- Check of it_o
  procedure chk_it
    (signal   it       : in    std_logic
    ;constant exp      : in    std_logic
    ;constant msg      : in    string
    );

  -- Check of an integer (latency)
  procedure chk_int
    (constant val      : in    integer
    ;constant exp      : in    integer
    ;constant msg      : in    string
    );

  -- Wait n rising edges
  procedure cycles
    (constant n        : in    natural
    ;signal   clk      : in    std_logic
    );

  -- Number of rising edges until it_o = '1', seen on the falling edges
  -- (max if it_o stays '0')
  procedure it_latency
    (signal   it       : in    std_logic
    ;constant max      : in    natural
    ;variable cnt      : out   natural
    ;signal   clk      : in    std_logic
    );

  -- Drive the NB_IO input pins (the NB_IO low bits of v) on a falling edge
  procedure set_pins
    (constant v        : in    byte_t
    ;signal   clk      : in    std_logic
    ;signal   pins     : out   std_logic_vector
    );

  -- Wait until a change of the pins is seen by the registers (synchronizer
  -- and edge detection), then a falling edge
  procedure settle
    (signal   clk      : in    std_logic
    );

  -- Reset pulse, released on a falling edge
  procedure do_reset
    (signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    );

end package tb_GPIO_bfm_pkg;

package body tb_GPIO_bfm_pkg is

  function lines
    (constant nb_io    : in    natural
    ) return byte_t is
    variable res : byte_t := (others => '0');
  begin
    res(nb_io-1 downto 0) := (others => '1');
    return res;
  end function;

  function lowest
    (constant v        : in    byte_t
    ) return byte_t is
    variable res : byte_t := (others => '0');
  begin
    for i in v'reverse_range loop
      if v(i) = '1'
      then
        res(i) := '1';
        return res;
      end if;
    end loop;
    return res;
  end function;

  procedure wr
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    sbi_write(addr_value => addr
             ,data_value => data
             ,msg        => msg
             ,clk        => clk
             ,sbi_if     => sbi_if
             ,scope      => C_TB_SCOPE
             ,config     => C_SBI_CFG
             );
  end procedure;

  procedure chk
    (constant addr     : in    unsigned
    ;constant data     : in    byte_t
    ;constant msg      : in    string
    ;signal   clk      : in    std_logic
    ;signal   sbi_if   : inout t_sbi_if
    ) is
  begin
    sbi_check(addr_value  => addr
             ,data_exp    => data
             ,msg         => msg
             ,clk         => clk
             ,sbi_if      => sbi_if
             ,alert_level => error
             ,scope       => C_TB_SCOPE
             ,config      => C_SBI_CFG
             );
  end procedure;

  procedure chk_pins
    (signal   pins     : in    std_logic_vector
    ;constant exp      : in    byte_t
    ;constant msg      : in    string
    ) is
  begin
    check_value(pins, exp(pins'length-1 downto 0), error, msg, C_TB_SCOPE);
  end procedure;

  procedure chk_it
    (signal   it       : in    std_logic
    ;constant exp      : in    std_logic
    ;constant msg      : in    string
    ) is
  begin
    check_value(it, exp, error, msg, C_TB_SCOPE);
  end procedure;

  procedure chk_int
    (constant val      : in    integer
    ;constant exp      : in    integer
    ;constant msg      : in    string
    ) is
  begin
    check_value(val, exp, error, msg, C_TB_SCOPE);
  end procedure;

  procedure cycles
    (constant n        : in    natural
    ;signal   clk      : in    std_logic
    ) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
  end procedure;

  procedure it_latency
    (signal   it       : in    std_logic
    ;constant max      : in    natural
    ;variable cnt      : out   natural
    ;signal   clk      : in    std_logic
    ) is
  begin
    cnt := max;
    for i in 1 to max loop
      wait until rising_edge(clk);
      wait until falling_edge(clk);
      if it = '1'
      then
        cnt := i;
        return;
      end if;
    end loop;
  end procedure;

  procedure set_pins
    (constant v        : in    byte_t
    ;signal   clk      : in    std_logic
    ;signal   pins     : out   std_logic_vector
    ) is
  begin
    wait until falling_edge(clk);
    pins <= v(pins'length-1 downto 0);
  end procedure;

  procedure settle
    (signal   clk      : in    std_logic
    ) is
  begin
    cycles(C_SYNC_CYCLES+2, clk);
    wait until falling_edge(clk);
  end procedure;

  procedure do_reset
    (signal   clk      : in    std_logic
    ;signal   arst_b   : out   std_logic
    ) is
  begin
    arst_b <= '0';
    wait for 100 ns;
    wait until falling_edge(clk);
    arst_b <= '1';
    wait until rising_edge(clk);
  end procedure;

end package body tb_GPIO_bfm_pkg;
