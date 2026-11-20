-------------------------------------------------------------------------------
-- Title      : tb_GPIO
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: UVVM/SBI self-checking testbench of sbi_GPIO (8 lines).
--              TESTS_LIST   : scenarios run in sequence, separated by ','
--                             (tb_GPIO_tests_pkg), each one after a reset
--                             pulse ; "" : build and elaboration only
--              DATA_OE_INIT : DATA_OE_INIT of the DUT
--              The legacy GPIO_v1 (hdl/legacy) runs next to the DUT on the
--              same bus and pins : a monitor compares rdata, ready, data_o
--              and data_oe_o of the two on every rising edge of the clock,
--              in every scenario.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-07-29  1.0      mrosiere Created
-- 2026-11-20  2.0      mrosiere TESTS_LIST, one package per scenario
--                               (tb_GPIO_<name>_pkg), helpers in
--                               tb_GPIO_bfm_pkg, reset pulse before each
--                               scenario, comparison with GPIO_v1 (was
--                               tb_GPIO_vs_v1)
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library asylum;
use     asylum.sbi_pkg.all;
use     asylum.string_pkg.all;
use     asylum.GPIO_pkg.all;
use     asylum.GPIO_csr_pkg.all;

library work;
use     work.tb_GPIO_bfm_pkg.all;
use     work.tb_GPIO_tests_pkg.all;

entity tb_GPIO is
  generic (
    TESTS_LIST       : string                        := ""               -- Scenarios, e.g. "output,input"
   ;DATA_OE_INIT     : std_logic_vector(8-1 downto 0) := (others => '0')  -- Direction of the lines after a reset
  );
end entity tb_GPIO;

architecture sim of tb_GPIO is

  constant C_SCOPE         : string  := "TB_GPIO";
  -- 8 lines : GPIO_v1 reads 0 above NB_IO, sbi_GPIO reads its 8-bit registers
  constant C_NB_IO         : natural := GPIO_DATA_WIDTH;

  signal   clk_i           : std_logic := '0';
  signal   clk_ena         : boolean   := true;
  signal   arst_b_i        : std_logic := '0';
  signal   arst_b_r        : std_logic := '0';

  signal   sbi_ini         : sbi_ini_t(addr (GPIO_ADDR_WIDTH-1 downto 0),
                                       wdata(GPIO_DATA_WIDTH-1 downto 0));
  signal   sbi_tgt         : sbi_tgt_t(rdata(GPIO_DATA_WIDTH-1 downto 0));
  signal   sbi_if          : t_sbi_if (addr (GPIO_ADDR_WIDTH-1 downto 0),
                                       wdata(GPIO_DATA_WIDTH-1 downto 0),
                                       rdata(GPIO_DATA_WIDTH-1 downto 0));

  signal   data_i          : std_logic_vector(C_NB_IO-1 downto 0) := (others => '0');
  signal   data_o          : std_logic_vector(C_NB_IO-1 downto 0);
  signal   data_oe_o       : std_logic_vector(C_NB_IO-1 downto 0);
  signal   it_o            : std_logic;

  -- GPIO_v1 : one input register (sbi_GPIO : two), data_i delayed by one cycle
  signal   v1_data_i       : std_logic_vector(C_NB_IO-1 downto 0);
  signal   v1_rdata        : std_logic_vector(GPIO_DATA_WIDTH-1 downto 0);
  signal   v1_busy         : std_logic;
  signal   v1_data_o       : std_logic_vector(C_NB_IO-1 downto 0);
  signal   v1_data_oe      : std_logic_vector(C_NB_IO-1 downto 0);

begin

  clock_generator(clk_i, clk_ena, C_CLK_PERIOD, "TB Clock");

  -----------------------------------------------------------------------------
  -- DUT
  -----------------------------------------------------------------------------
  dut : sbi_GPIO
    generic map
    (NAME         => "GPIO"
    ,NB_IO        => C_NB_IO
    ,DATA_OE_INIT => DATA_OE_INIT
    )
    port map
    (clk_i        => clk_i
    ,cke_i        => '1'
    ,arstn_i      => arst_b_i
    ,sbi_ini_i    => sbi_ini
    ,sbi_tgt_o    => sbi_tgt
    ,data_i       => data_i
    ,data_o       => data_o
    ,data_oe_o    => data_oe_o
    ,it_o         => it_o
    );

  sbi_ini.cs    <= sbi_if.cs;
  sbi_ini.addr  <= std_logic_vector(sbi_if.addr);
  sbi_ini.re    <= sbi_if.rena;
  sbi_ini.we    <= sbi_if.wena;
  sbi_ini.wdata <= sbi_if.wdata;
  sbi_if.ready  <= sbi_tgt.ready;
  sbi_if.rdata  <= sbi_tgt.rdata;

  -----------------------------------------------------------------------------
  -- Reference : legacy GPIO_v1, same bus, same pins
  -----------------------------------------------------------------------------
  ref_v1 : GPIO_v1
    generic map
    (SIZE_ADDR     => GPIO_ADDR_WIDTH
    ,SIZE_DATA     => GPIO_DATA_WIDTH
    ,NB_IO         => C_NB_IO
    ,DATA_OE_INIT  => DATA_OE_INIT
    ,DATA_OE_FORCE => (C_NB_IO-1 downto 0 => '0')
    )
    port map
    (clk_i         => clk_i
    ,cke_i         => '1'
    ,arstn_i       => arst_b_i
    ,cs_i          => sbi_ini.cs
    ,re_i          => sbi_ini.re
    ,we_i          => sbi_ini.we
    ,addr_i        => sbi_ini.addr
    ,wdata_i       => sbi_ini.wdata
    ,rdata_o       => v1_rdata
    ,busy_o        => v1_busy
    ,data_i        => v1_data_i
    ,data_o        => v1_data_o
    ,data_oe_o     => v1_data_oe
    );

  process(clk_i)
  begin
    if rising_edge(clk_i)
    then
      v1_data_i <= data_i;
    end if;
  end process;

  -- The data_in register of sbi_GPIO is reset, the input register of GPIO_v1
  -- is not : compare from the first rising edge after the reset release
  process(clk_i, arst_b_i)
  begin
    if arst_b_i = '0'
    then
      arst_b_r <= '0';
    elsif rising_edge(clk_i)
    then
      arst_b_r <= '1';
    end if;
  end process;

  -- Compared on the rising edge : the bus request is stable and the outputs
  -- still hold the values of the cycle that ends
  p_compare : process
  begin
    wait until rising_edge(clk_i);
    if arst_b_r = '1'
    then
      check_value(value => sbi_tgt.rdata, exp => v1_rdata    , alert_level => error, msg => "rdata = GPIO_v1"    , scope => C_SCOPE, msg_id => ID_NEVER);
      check_value(value => sbi_tgt.ready, exp => not v1_busy , alert_level => error, msg => "ready = GPIO_v1"    , scope => C_SCOPE, msg_id => ID_NEVER);
      check_value(value => data_o       , exp => v1_data_o   , alert_level => error, msg => "data_o = GPIO_v1"   , scope => C_SCOPE, msg_id => ID_NEVER);
      check_value(value => data_oe_o    , exp => v1_data_oe  , alert_level => error, msg => "data_oe_o = GPIO_v1", scope => C_SCOPE, msg_id => ID_NEVER);
    end if;
  end process p_compare;

  -----------------------------------------------------------------------------
  -- Sequencer
  -----------------------------------------------------------------------------
  p_sequencer : process
  begin
    log(ID_LOG_HDR, "DATA_OE_INIT = " & to_string(DATA_OE_INIT, BIN, AS_IS) & ", TESTS_LIST : " & TESTS_LIST, C_SCOPE);

    -- Every name is checked before the first scenario
    for i in 1 to list_length(TESTS_LIST) loop
      if not list_contains(C_TESTS, list_item(TESTS_LIST, i))
      then
        alert(TB_ERROR, "Unknown test """ & list_item(TESTS_LIST, i) & """ (tests : " & C_TESTS & ")", C_SCOPE);
      end if;
    end loop;

    for i in 1 to list_length(TESTS_LIST) loop
      -- Reset pulse, bus inactive and pins at 0 : each scenario starts from reset
      sbi_if <= init_sbi_if_signals(GPIO_ADDR_WIDTH, GPIO_DATA_WIDTH);
      data_i <= (others => '0');
      do_reset(clk_i, arst_b_i);

      log(ID_LOG_HDR, "TEST " & integer'image(i) & "/" & integer'image(list_length(TESTS_LIST)) & " : " & list_item(TESTS_LIST, i), C_SCOPE);
      run_test(list_item(TESTS_LIST, i), DATA_OE_INIT, clk_i, arst_b_i, sbi_if, data_i, data_o, data_oe_o, it_o);
    end loop;

    report_alert_counters(FINAL);
    std.env.stop;
    wait;
  end process p_sequencer;

end architecture sim;
