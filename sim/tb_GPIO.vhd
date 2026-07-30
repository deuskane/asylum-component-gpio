-------------------------------------------------------------------------------
-- Title      : tb_GPIO
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO.vhd
-- Author     : Copilot
-------------------------------------------------------------------------------
-- Description: UVVM/SBI testbench for the SBI GPIO DUT
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_sbi;
use     bitvis_vip_sbi.sbi_bfm_pkg.all;

library bitvis_vip_gpio;
use     bitvis_vip_gpio.gpio_bfm_pkg.all;

library asylum;
use     asylum.sbi_pkg.all;
use     asylum.GPIO_pkg.all;
use     asylum.GPIO_csr_pkg.all;

entity tb_GPIO is
end tb_GPIO;

architecture sim of tb_GPIO is

  constant C_SCOPE         : string := "TB_GPIO";
  constant GPIO_ADDR_WIDTH : natural := 2;
  constant GPIO_DATA_WIDTH : natural := 8;
  constant GPIO_OE_INIT     : std_logic_vector(GPIO_DATA_WIDTH-1 downto 0) := (others => '0');

  signal clk_i             : std_logic := '0';
  signal clk_ena           : boolean   := true;
  signal cke_i             : std_logic := '1';
  signal arstn_i           : std_logic := '0';

  signal sbi_ini           : sbi_ini_t(addr (GPIO_ADDR_WIDTH-1 downto 0),
                                       wdata(GPIO_DATA_WIDTH-1 downto 0));
  signal sbi_tgt           : sbi_tgt_t(rdata(GPIO_DATA_WIDTH-1 downto 0));

  signal sbi_if            : t_sbi_if(addr (GPIO_ADDR_WIDTH-1 downto 0),
                                      wdata(GPIO_DATA_WIDTH-1 downto 0),
                                      rdata(GPIO_DATA_WIDTH-1 downto 0));

  signal data_i            : std_logic_vector(GPIO_DATA_WIDTH-1 downto 0) := (others => '0');
  signal data_o            : std_logic_vector(GPIO_DATA_WIDTH-1 downto 0);
  signal data_oe_o         : std_logic_vector(GPIO_DATA_WIDTH-1 downto 0);
  signal it_o              : std_logic;

begin

  arstn_i <= '0', '1' after 100 ns;

  clock_generator(clk_i, clk_ena, 20 ns, "TB Clock");

  ins_dut : sbi_GPIO
    generic map (
      NB_IO        => GPIO_DATA_WIDTH,
      DATA_OE_INIT => GPIO_OE_INIT
    )
    port map (
      clk_i       => clk_i,
      cke_i       => cke_i,
      arstn_i     => arstn_i,
      sbi_ini_i   => sbi_ini,
      sbi_tgt_o   => sbi_tgt,
      data_i      => data_i(GPIO_DATA_WIDTH-1 downto 0),
      data_o      => data_o,
      data_oe_o   => data_oe_o,
      it_o        => it_o
    );

  sbi_ini.cs                               <= sbi_if.cs;
  sbi_ini.addr                             <= std_logic_vector(sbi_if.addr(GPIO_ADDR_WIDTH-1 downto 0));
  sbi_ini.re                               <= sbi_if.rena;
  sbi_ini.we                               <= sbi_if.wena;
  sbi_ini.wdata                            <= sbi_if.wdata(GPIO_DATA_WIDTH-1 downto 0);
  sbi_if.ready                             <= sbi_tgt.ready;
  sbi_if.rdata(GPIO_DATA_WIDTH-1 downto 0) <= sbi_tgt.rdata;

  process
    variable v_data : std_logic_vector(GPIO_DATA_WIDTH-1 downto 0);
  begin
    sbi_if <= init_sbi_if_signals(GPIO_ADDR_WIDTH, GPIO_DATA_WIDTH);
    wait until arstn_i = '1';
    wait until rising_edge(clk_i);

    log(ID_SEQUENCER, "Reset released, starting GPIO SBI test", C_SCOPE);

    log(ID_LOG_HDR, "Check post reset", C_SCOPE);
    gpio_set  (x"A5"       , "Drive GPIO input  value"      , data_i   , C_SCOPE);
    gpio_check(x"00"       , "Check GPIO output value"      , data_o   , error, C_SCOPE);
    gpio_check(x"00"       , "Check GPIO output enable mask", data_oe_o, error, C_SCOPE);

    wait until rising_edge(clk_i);
    sbi_check(GPIO_DATA    , x"A5", "Read data"    , clk_i, sbi_if);
    sbi_check(GPIO_DATA_OE , x"00", "Read data_oe" , clk_i, sbi_if);
    sbi_check(GPIO_DATA_IN , x"A5", "Read data_in" , clk_i, sbi_if);
    sbi_check(GPIO_DATA_OUT, x"00", "Read data_out", clk_i, sbi_if);
    

    log(ID_LOG_HDR, "Configure direction to output and write a value", C_SCOPE);
    sbi_write(GPIO_DATA_OE , x"FF", "Set GPIO direction to output", clk_i, sbi_if);
    gpio_set  (x"A5", "Drive GPIO output value", data_i, C_SCOPE);
    gpio_check(x"00", "Check GPIO output value", data_o, error, C_SCOPE);
    gpio_check(x"FF", "Check GPIO output enable mask", data_oe_o, error, C_SCOPE);

    wait until rising_edge(clk_i);
    sbi_write(GPIO_DATA    , x"21", "Write output value", clk_i, sbi_if);
    wait until rising_edge(clk_i);
    gpio_check(x"21", "Check GPIO output value", data_o, error, C_SCOPE);
    sbi_check(GPIO_DATA    , x"21", "Read data"    , clk_i, sbi_if);
    sbi_check(GPIO_DATA_OE , x"FF", "Read data_oe" , clk_i, sbi_if);
    sbi_check(GPIO_DATA_IN , x"A5", "Read data_in" , clk_i, sbi_if);
    sbi_check(GPIO_DATA_OUT, x"21", "Read data_out", clk_i, sbi_if);

    log(ID_LOG_HDR, "Switch to input mode and verify input data read path", C_SCOPE);
    gpio_set(x"3C", "Drive input value via GPIO VIP", data_i, C_SCOPE);
    wait until rising_edge(clk_i);
    sbi_write(GPIO_DATA_OE , x"00", "Set GPIO direction to input", clk_i, sbi_if);

    sbi_check(GPIO_DATA    , x"3C", "Read data"    , clk_i, sbi_if);
    sbi_check(GPIO_DATA_OE , x"00", "Read data_oe" , clk_i, sbi_if);
    sbi_check(GPIO_DATA_IN , x"3C", "Read data_in" , clk_i, sbi_if);
    sbi_check(GPIO_DATA_OUT, x"21", "Read data_out", clk_i, sbi_if);

    gpio_check(x"3C", "Check GPIO input value", data_i, error, C_SCOPE);
    gpio_check(x"00", "Check GPIO output enable is inactive", data_oe_o, error, C_SCOPE);

    report "[TB_GPIO] All SBI GPIO checks passed";
    report_alert_counters(FINAL);
    std.env.stop;
    wait;
  end process;

end sim;
