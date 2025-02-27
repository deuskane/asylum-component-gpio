-------------------------------------------------------------------------------
-- Title      : tb_GPIO_bidir
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_bidir.vhd
-- Author     : mrosiere
-- Company    : 
-- Created    : 2017-03-25
-- Last update: 2025-02-27
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2022-07-11  1.1      mrosiere DATA_OE_<INIT/FORCE> in NB_IO
-- 2017-03-25  1.0      mrosiere Created
-------------------------------------------------------------------------------

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.numeric_bit.all;
--use ieee.std_logic_arith.all;

library asylum;

entity tb_GPIO_bidir is

end tb_GPIO_bidir;

architecture tb of tb_GPIO_bidir is

  -- =====[ Constants ]===========================
  constant SIZE_ADDR        : natural:=8;     -- Bus Address Width
  constant SIZE_DATA        : natural:=8;     -- Bus Data    Width
  constant NB_IO            : natural:=8;     -- Number of IO. Must be <= SIZE_DATA
  constant DATA_OE_INIT     : std_logic_vector(NB_IO-1 downto 0):=(others=>'0'); -- Direction of the IO after a reset
  constant DATA_OE_FORCE    : std_logic_vector(NB_IO-1 downto 0):=(others=>'0'); -- Can change the direction of the IO
  constant IT_ENABLE        : boolean:=false; -- GPIO can generate interruption

  -- =====[ Signals ]=============================
  signal clk_i            : std_logic := '0';
  signal cke_i            : std_logic;
  signal arstn_i          : std_logic;
  signal cs_i             : std_logic;
  signal re_i             : std_logic;
  signal we_i             : std_logic;
  signal addr_i           : std_logic_vector (SIZE_ADDR-1 downto 0);
  signal wdata_i          : std_logic_vector (SIZE_DATA-1 downto 0);
  signal data_i           : std_logic_vector (NB_IO-1     downto 0);
  signal interrupt_ack_i  : std_logic;

  signal rdata_o1         : std_logic_vector (SIZE_DATA-1 downto 0);
  signal busy_o1          : std_logic;
  signal data_o1          : std_logic_vector (NB_IO-1     downto 0);
  signal data_oe_o1       : std_logic_vector (NB_IO-1     downto 0);
  signal interrupt_o1     : std_logic;

  signal rdata_o2         : std_logic_vector (SIZE_DATA-1 downto 0);
  signal busy_o2          : std_logic;
  signal data_o2          : std_logic_vector (NB_IO-1     downto 0);
  signal data_oe_o2       : std_logic_vector (NB_IO-1     downto 0);
  signal interrupt_o2     : std_logic;

  -------------------------------------------------------
  -- run
  -------------------------------------------------------
  procedure xrun
    (constant n     : in positive;           -- nb cycle
     signal   clk_i : in std_logic
     ) is
    
  begin
    for i in 0 to n-1
    loop
      wait until rising_edge(clk_i);        
    end loop;  -- i
  end xrun;

  procedure run
    (constant n     : in positive           -- nb cycle
     ) is
    
  begin
    xrun(n,clk_i);
  end run;

  -----------------------------------------------------
  -- Test signals
  -----------------------------------------------------
  signal test_en   : boolean   := false;
  signal test_done : std_logic := '0';
  signal test_ok   : std_logic := '0';

begin

  ------------------------------------------------
  -- Instance of DUT
  ------------------------------------------------
  GPIO : entity asylum.GPIO(rtl)
  generic map(
    SIZE_ADDR        => SIZE_ADDR      ,
    SIZE_DATA        => SIZE_DATA      ,
    NB_IO            => NB_IO          ,
    DATA_OE_INIT     => DATA_OE_INIT   ,
    DATA_OE_FORCE    => DATA_OE_FORCE  ,
    IT_ENABLE        => IT_ENABLE    
    )
  port map(
    clk_i            => clk_i          ,
    cke_i            => cke_i          ,
    arstn_i          => arstn_i        ,
    cs_i             => cs_i           ,
    re_i             => re_i           ,
    we_i             => we_i           ,
    addr_i           => addr_i         ,
    wdata_i          => wdata_i        ,
    rdata_o          => rdata_o1       ,
    busy_o           => busy_o1        ,

    data_i           => data_i         ,
    data_o           => data_o1        ,
    data_oe_o        => data_oe_o1     ,
    
    interrupt_o      => interrupt_o1   ,
    interrupt_ack_i  => interrupt_ack_i
    );

  GPIO_old : entity asylum.GPIO(rtl_without_csr)
  generic map(
    SIZE_ADDR        => SIZE_ADDR      ,
    SIZE_DATA        => SIZE_DATA      ,
    NB_IO            => NB_IO          ,
    DATA_OE_INIT     => DATA_OE_INIT   ,
    DATA_OE_FORCE    => DATA_OE_FORCE  ,
    IT_ENABLE        => IT_ENABLE    
    )
  port map(
    clk_i            => clk_i          ,
    cke_i            => cke_i          ,
    arstn_i          => arstn_i        ,
    cs_i             => cs_i           ,
    re_i             => re_i           ,
    we_i             => we_i           ,
    addr_i           => addr_i         ,
    wdata_i          => wdata_i        ,
    rdata_o          => rdata_o2       ,
    busy_o           => busy_o2        ,

    data_i           => data_i         ,
    data_o           => data_o2        ,
    data_oe_o        => data_oe_o2     ,
    
    interrupt_o      => interrupt_o2   ,
    interrupt_ack_i  => interrupt_ack_i
    );

  ------------------------------------------------
  -- Clock process
  ------------------------------------------------
  clk_i <= not test_done and not clk_i after 5 ns;
  
  ------------------------------------------------
  -- Test process
  ------------------------------------------------
  -- purpose: Testbench process
  -- type   : combinational
  -- inputs : 
  -- outputs: All dut design with clk_i
  tb_gen: process is
  begin  -- process tb_gen
    report "[TESTBENCH] Test Begin";
    
    run(1);

    -- Reset
    report "[TESTBENCH] Reset";
    arstn_i         <= '0';
    cke_i           <= '1';

    cs_i            <= '0';
    re_i            <= '0';
    we_i            <= '0';
    addr_i          <= X"00";
    wdata_i         <= X"00";
    interrupt_ack_i <= '0';
    data_i          <= (others => 'L');
    
    run(1);

    arstn_i         <= '1';
    run(1);

    report "[TESTBENCH] Goto OUT mode";
    cs_i            <= '1';
    addr_i          <= X"01";
    wdata_i         <= X"FF";
    run(1);
    we_i            <= '1';

    run(1);
    cs_i            <= '0';
    we_i            <= '0';

    test_en         <= true;


    
    for i in 0 to SIZE_DATA-1 loop
    report "[TESTBENCH] Write data";
    cs_i            <= '1';
    addr_i          <= X"00";
    wdata_i         <= X"00";
    wdata_i(i)      <= '1';
    run(1);
    we_i            <= '1';

    run(1);
    cs_i            <= '0';
    we_i            <= '0';
    end loop;  -- i

    report "[TESTBENCH] Goto IN mode";
    cs_i            <= '1';
    addr_i          <= X"01";
    wdata_i         <= X"00";
    run(1);
    we_i            <= '1';

    run(1);
    cs_i            <= '0';
    we_i            <= '0';
    
    for i in 0 to SIZE_DATA-1 loop
    report "[TESTBENCH] Write data";
    cs_i            <= '1';
    addr_i          <= X"00";
    data_i          <= (others => 'L');
    data_i(i)       <= 'H';
    run(1);
    re_i            <= '1';

    run(1);
    cs_i            <= '0';
    re_i            <= '0';
    end loop;  -- i
    
    
    test_ok   <= '1';

    run(1);
    test_done <= '1';
    run(1);
  end process tb_gen;

  gen_test_done: process (test_done) is
  begin  -- process gen_test_done
    if test_done'event and test_done = '1' then  -- rising clock edge
      if test_ok = '1' then
        report "[TESTBENCH] Test OK";
      else
        report "[TESTBENCH] Test KO" severity failure;
      end if;
      
    end if;
  end process gen_test_done;

  -- assert (rdata_o1     = rdata_o2    ) report "Diff rdata_o    " severity failure;
  -- assert (busy_o1      = busy_o2     ) report "Diff busy_o     " severity failure;
  -- assert (data_o1      = data_o2     ) report "Diff data_o     " severity failure;
  -- assert (data_oe_o1   = data_oe_o2  ) report "Diff data_oe_o  " severity failure;
  -- assert (interrupt_o1 = interrupt_o2) report "Diff interrupt_o" severity failure;
  
end tb;
