-------------------------------------------------------------------------------
-- Title      : tb_GPIO_bidir
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : tb_GPIO_bidir.vhd
-- Author     : mrosiere
-- Company    : 
-- Created    : 2017-03-25
-- Last update: 2025-11-22
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
use     asylum.sbi_pkg.all;
use     asylum.GPIO_pkg.all;

entity tb_GPIO_bidir is

end tb_GPIO_bidir;

architecture tb of tb_GPIO_bidir is

  -- =====[ Constants ]===========================
  constant SIZE_ADDR        : natural:=2;     -- Bus Address Width
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

  signal sbi_ini_i        : sbi_ini_t(addr (SIZE_ADDR-1 downto 0),
                                      wdata(SIZE_DATA-1 downto 0));          
  signal sbi_tgt_o1       : sbi_tgt_t(rdata(SIZE_DATA-1 downto 0));          
  signal sbi_tgt_o2       : sbi_tgt_t(rdata(SIZE_DATA-1 downto 0));          
  
  -------------------------------------------------------
  -- run
  -------------------------------------------------------
  procedure xrun
    (constant n      : in positive;           -- nb cycle
     signal   clk_i  : in std_logic;
     constant posedge: in boolean
     ) is
    
  begin
    for i in 0 to n-1
    loop
      if posedge
      then
        wait until rising_edge(clk_i);          
      else
        wait until falling_edge(clk_i);          
      end if;
      
    end loop;  -- i
  end xrun;

  procedure run
    (constant n      : in positive;           -- nb cycle
     constant posedge: in boolean := true     -- nb cycle
     ) is
    
  begin
    xrun(n,clk_i,posedge);
  end run;

  function to_string ( a: std_logic_vector) return string is
    variable b : string (1 to a'length) := (others => NUL);
    variable stri : integer := 1; 
  begin
    for i in a'range loop
      b(stri) := std_logic'image(a((i)))(2);
      stri := stri+1;
    end loop;
    return b;
  end function;

  function to_string ( a: std_logic) return string is
  begin
    return std_logic'image(a);
  end function;

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
  sbi_ini_i.cs    <= cs_i   ;
  sbi_ini_i.we    <= we_i   ;
  sbi_ini_i.re    <= re_i   ;
  sbi_ini_i.addr  <= addr_i ;
  sbi_ini_i.wdata <= wdata_i;

  rdata_o1        <= sbi_tgt_o1.rdata;
  busy_o1         <= not sbi_tgt_o1.ready ;


  dut_GPIO : sbi_GPIO
  generic map(
    NB_IO            => NB_IO          ,
    DATA_OE_INIT     => DATA_OE_INIT   ,
    IT_ENABLE        => IT_ENABLE    
    )
  port map(
    clk_i            => clk_i          ,
    cke_i            => cke_i          ,
    arstn_i          => arstn_i        ,
    sbi_ini_i        => sbi_ini_i      , 
    sbi_tgt_o        => sbi_tgt_o1     ,
   
    data_i           => data_i         ,
    data_o           => data_o1        ,
    data_oe_o        => data_oe_o1     ,
    
    interrupt_o      => interrupt_o1   ,
    interrupt_ack_i  => interrupt_ack_i
    );

  dut_GPIO_v1 : GPIO_v1
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
    addr_i          <=  "00";
    wdata_i         <= X"00";
    interrupt_ack_i <= '0';
    data_i          <= (others => 'L');
    
    run(1);

    arstn_i         <= '1';

    test_en         <= true;

    run(1);

    report "[TESTBENCH] Goto OUT mode";
    cs_i            <= '1';
    addr_i          <=  "01";
    wdata_i         <= X"FF";
    run(1);
    we_i            <= '1';

    run(1);
    cs_i            <= '0';
    we_i            <= '0';
    
    for i in 0 to SIZE_DATA-1 loop
    report "[TESTBENCH] Write data";
    cs_i            <= '1';
    addr_i          <=  "00";
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
    addr_i          <=  "01";
    wdata_i         <= X"00";
    run(1);
    we_i            <= '1';

    run(1);
    cs_i            <= '0';
    we_i            <= '0';
    
    for i in 0 to SIZE_DATA-1 loop
    report "[TESTBENCH] Write data";
    cs_i            <= '1';
    addr_i          <=  "00";
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

  process
  begin
    run(1,false);

    if (test_en)
    then
      assert (rdata_o1     = rdata_o2    ) report "Diff rdata_o    "&to_string(rdata_o1    )&" - "&to_string(rdata_o2    ) severity failure;
      assert (busy_o1      = busy_o2     ) report "Diff busy_o     "&to_string(busy_o1     )&" - "&to_string(busy_o2     ) severity failure;
      assert (data_o1      = data_o2     ) report "Diff data_o     "&to_string(data_o1     )&" - "&to_string(data_o2     ) severity failure;
      assert (data_oe_o1   = data_oe_o2  ) report "Diff data_oe_o  "&to_string(data_oe_o1  )&" - "&to_string(data_oe_o2  ) severity failure;
      assert (interrupt_o1 = interrupt_o2) report "Diff interrupt_o"&to_string(interrupt_o1)&" - "&to_string(interrupt_o2) severity failure;
    end if;
  end process;
  
  
end tb;
