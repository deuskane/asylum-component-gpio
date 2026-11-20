-------------------------------------------------------------------------------
-- Title      : tb_GPIO_irq
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_irq.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description: UVVM/SBI self-checking testbench of sbi_GPIO_irq.
--              TESTS_LIST   : scenarios run in sequence, separated by ','
--                             (tb_GPIO_irq_tests_pkg), each one after a
--                             reset pulse ; "" : build and elaboration only
--              NB_IO, DATA_OE_INIT, IRQ_POSEDGE, IRQ_NEGEDGE : generics
--                             of the DUT
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-07-31  1.0      mrosiere Created
-- 2026-11-20  2.0      mrosiere TESTS_LIST, one package per scenario
--                               (tb_GPIO_irq_<name>_pkg), helpers in
--                               tb_GPIO_bfm_pkg, reset pulse before each
--                               scenario, generics of the DUT
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
use     asylum.GPIO_irq_csr_pkg.all;

library work;
use     work.tb_GPIO_bfm_pkg.all;
use     work.tb_GPIO_irq_tests_pkg.all;

entity tb_GPIO_irq is
  generic (
    TESTS_LIST       : string                        := ""            -- Scenarios, e.g. "posedge,mask"
   ;NB_IO            : positive                      := 4             -- Number of lines (1 to 8)
   ;DATA_OE_INIT     : std_logic_vector(8-1 downto 0) := "00000110"    -- Direction of the lines after a reset
   ;IRQ_POSEDGE      : std_logic_vector(8-1 downto 0) := "00001010"    -- Interrupt on rising edge
   ;IRQ_NEGEDGE      : std_logic_vector(8-1 downto 0) := "00001100"    -- Interrupt on falling edge
  );
end entity tb_GPIO_irq;

architecture sim of tb_GPIO_irq is

  constant C_SCOPE         : string  := "TB_GPIO_IRQ";

  signal   clk_i           : std_logic := '0';
  signal   clk_ena         : boolean   := true;
  signal   arst_b_i        : std_logic := '0';

  signal   sbi_ini         : sbi_ini_t(addr (GPIO_IRQ_ADDR_WIDTH-1 downto 0),
                                       wdata(GPIO_IRQ_DATA_WIDTH-1 downto 0));
  signal   sbi_tgt         : sbi_tgt_t(rdata(GPIO_IRQ_DATA_WIDTH-1 downto 0));
  signal   sbi_if          : t_sbi_if (addr (GPIO_IRQ_ADDR_WIDTH-1 downto 0),
                                       wdata(GPIO_IRQ_DATA_WIDTH-1 downto 0),
                                       rdata(GPIO_IRQ_DATA_WIDTH-1 downto 0));

  signal   data_i          : std_logic_vector(NB_IO-1 downto 0) := (others => '0');
  signal   data_o          : std_logic_vector(NB_IO-1 downto 0);
  signal   data_oe_o       : std_logic_vector(NB_IO-1 downto 0);
  signal   it_o            : std_logic;

begin

  clock_generator(clk_i, clk_ena, C_CLK_PERIOD, "TB Clock");

  -----------------------------------------------------------------------------
  -- DUT
  -----------------------------------------------------------------------------
  dut : sbi_GPIO_irq
    generic map
    (NAME         => "GPIO_irq"
    ,NB_IO        => NB_IO
    ,DATA_OE_INIT => DATA_OE_INIT
    ,IRQ_POSEDGE  => IRQ_POSEDGE
    ,IRQ_NEGEDGE  => IRQ_NEGEDGE
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
  -- Sequencer
  -----------------------------------------------------------------------------
  p_sequencer : process
  begin
    log(ID_LOG_HDR, "NB_IO = " & integer'image(NB_IO) & ", DATA_OE_INIT = " & to_string(DATA_OE_INIT, BIN, AS_IS) & ", IRQ_POSEDGE = " & to_string(IRQ_POSEDGE, BIN, AS_IS) & ", IRQ_NEGEDGE = " & to_string(IRQ_NEGEDGE, BIN, AS_IS) & ", TESTS_LIST : " & TESTS_LIST, C_SCOPE);

    -- Every name is checked before the first scenario
    for i in 1 to list_length(TESTS_LIST) loop
      if not list_contains(C_TESTS, list_item(TESTS_LIST, i))
      then
        alert(TB_ERROR, "Unknown test """ & list_item(TESTS_LIST, i) & """ (tests : " & C_TESTS & ")", C_SCOPE);
      elsif not test_applies(list_item(TESTS_LIST, i), NB_IO, IRQ_POSEDGE)
      then
        alert(TB_ERROR, "Test """ & list_item(TESTS_LIST, i) & """ needs a line with IRQ_POSEDGE", C_SCOPE);
      end if;
    end loop;

    for i in 1 to list_length(TESTS_LIST) loop
      -- Reset pulse, bus inactive and pins at 0 : each scenario starts from reset
      sbi_if <= init_sbi_if_signals(GPIO_IRQ_ADDR_WIDTH, GPIO_IRQ_DATA_WIDTH);
      data_i <= (others => '0');
      do_reset(clk_i, arst_b_i);

      log(ID_LOG_HDR, "TEST " & integer'image(i) & "/" & integer'image(list_length(TESTS_LIST)) & " : " & list_item(TESTS_LIST, i), C_SCOPE);
      run_test(list_item(TESTS_LIST, i), NB_IO, DATA_OE_INIT, IRQ_POSEDGE, IRQ_NEGEDGE, clk_i, arst_b_i, sbi_if, data_i, data_o, data_oe_o, it_o);
    end loop;

    report_alert_counters(FINAL);
    std.env.stop;
    wait;
  end process p_sequencer;

end architecture sim;
