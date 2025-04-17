-- Generated VHDL Module for GPIO


library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

library work;
use     work.GPIO_csr_pkg.ALL;
library work;
use     work.pbi_pkg.all;

--==================================
-- Module      : GPIO
-- Description : CSR for General Purpose I/O
-- Width       : 8
--==================================
entity GPIO_registers is
  port (
    -- Clock and Reset
    clk_i      : in  std_logic;
    arst_b_i   : in  std_logic;
    -- Bus
    pbi_ini_i  : in  pbi_ini_t;
    pbi_tgt_o  : out pbi_tgt_t;
    -- CSR
    sw2hw_o    : out GPIO_sw2hw_t;
    hw2sw_i    : in  GPIO_hw2sw_t
  );
end entity GPIO_registers;

architecture rtl of GPIO_registers is

  signal   sig_wcs   : std_logic;
  signal   sig_we    : std_logic;
  signal   sig_waddr : std_logic_vector(pbi_ini_i.addr'length-1 downto 0);
  signal   sig_wdata : std_logic_vector(pbi_ini_i.wdata'length-1 downto 0);

  signal   sig_rcs   : std_logic;
  signal   sig_re    : std_logic;
  signal   sig_raddr : std_logic_vector(pbi_ini_i.addr'length-1 downto 0);
  signal   sig_rdata : std_logic_vector(pbi_tgt_o.rdata'length-1 downto 0);
  signal   sig_rbusy : std_logic;

  signal   data_wcs       : std_logic;
  signal   data_we        : std_logic;
  signal   data_wdata     : std_logic_vector(8-1 downto 0);
  signal   data_rcs       : std_logic;
  signal   data_re        : std_logic;
  signal   data_rdata     : std_logic_vector(8-1 downto 0);
  signal   data_rbusy     : std_logic;
  signal   data_value_rdata : std_logic_vector(7 downto 0);

  signal   data_oe_wcs       : std_logic;
  signal   data_oe_we        : std_logic;
  signal   data_oe_wdata     : std_logic_vector(8-1 downto 0);
  signal   data_oe_rcs       : std_logic;
  signal   data_oe_re        : std_logic;
  signal   data_oe_rdata     : std_logic_vector(8-1 downto 0);
  signal   data_oe_rbusy     : std_logic;
  signal   data_oe_value_rdata : std_logic_vector(7 downto 0);

  signal   data_in_wcs       : std_logic;
  signal   data_in_we        : std_logic;
  signal   data_in_wdata     : std_logic_vector(8-1 downto 0);
  signal   data_in_rcs       : std_logic;
  signal   data_in_re        : std_logic;
  signal   data_in_rdata     : std_logic_vector(8-1 downto 0);
  signal   data_in_rbusy     : std_logic;
  signal   data_in_value_rdata : std_logic_vector(7 downto 0);

  signal   data_out_wcs       : std_logic;
  signal   data_out_we        : std_logic;
  signal   data_out_wdata     : std_logic_vector(8-1 downto 0);
  signal   data_out_rcs       : std_logic;
  signal   data_out_re        : std_logic;
  signal   data_out_rdata     : std_logic_vector(8-1 downto 0);
  signal   data_out_rbusy     : std_logic;
  signal   data_out_value_rdata : std_logic_vector(7 downto 0);

begin  -- architecture rtl

  -- Interface 
  sig_wcs   <= pbi_ini_i.cs;
  sig_we    <= pbi_ini_i.we;
  sig_waddr <= pbi_ini_i.addr;
  sig_wdata <= pbi_ini_i.wdata;

  sig_rcs   <= pbi_ini_i.cs;
  sig_re    <= pbi_ini_i.re;
  sig_raddr <= pbi_ini_i.addr;
  pbi_tgt_o.rdata <= sig_rdata;
  pbi_tgt_o.busy <= sig_rbusy;

  --==================================
  -- Register    : data
  -- Description : data - with data_oe mask apply
  -- Address     : 0x0
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : ext
  --==================================
  --==================================
  -- Field       : value
  -- Description : Data with data_oe with mask apply
  -- Width       : 8
  --==================================


  data_rcs     <= '1' when     (sig_raddr(GPIO_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(0,GPIO_ADDR_WIDTH))) else '0';
  data_re      <= sig_rcs and data_rcs and sig_re;
  data_rdata   <= (
    7 => data_value_rdata(7),
    6 => data_value_rdata(6),
    5 => data_value_rdata(5),
    4 => data_value_rdata(4),
    3 => data_value_rdata(3),
    2 => data_value_rdata(2),
    1 => data_value_rdata(1),
    0 => data_value_rdata(0),
    others => '0');

  data_wcs     <= '0';
  data_we      <= '0';
  data_wdata   <= (others=>'0');

  ins_data : entity work.csr_ext(rtl)
    generic map
      (WIDTH         => 8
      )
    port map
      (clk_i         => clk_i
      ,arst_b_i      => arst_b_i
      ,sw_wd_i       => data_wdata(7 downto 0)
      ,sw_rd_o       => data_value_rdata
      ,sw_we_i       => data_we
      ,sw_re_i       => data_re
      ,sw_busy_o     => data_rbusy
      ,hw_wd_i       => hw2sw_i.data.value
      ,hw_rd_o       => sw2hw_o.data.value
      ,hw_we_i       => hw2sw_i.data.we
      ,hw_sw_re_o    => sw2hw_o.data.re
      ,hw_sw_we_o      => open
      );

  --==================================
  -- Register    : data_oe
  -- Description : GPIO Direction
  -- Address     : 0x1
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : GPIO Direction : 0 input, 1 output
  -- Width       : 8
  --==================================


  data_oe_rcs     <= '1' when     (sig_raddr(GPIO_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(1,GPIO_ADDR_WIDTH))) else '0';
  data_oe_re      <= sig_rcs and data_oe_rcs and sig_re;
  data_oe_rdata   <= (
    7 => data_oe_value_rdata(7),
    6 => data_oe_value_rdata(6),
    5 => data_oe_value_rdata(5),
    4 => data_oe_value_rdata(4),
    3 => data_oe_value_rdata(3),
    2 => data_oe_value_rdata(2),
    1 => data_oe_value_rdata(1),
    0 => data_oe_value_rdata(0),
    others => '0');

  data_oe_wcs     <= '1' when     (sig_waddr(GPIO_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(1,GPIO_ADDR_WIDTH))) else '0';
  data_oe_we      <= sig_wcs and data_oe_wcs and sig_we;
  data_oe_wdata   <= sig_wdata;

  ins_data_oe : entity work.csr_reg(rtl)
    generic map
      (WIDTH         => 8
      ,INIT          => "00000000"
      ,MODEL         => "rw"
      )
    port map
      (clk_i         => clk_i
      ,arst_b_i      => arst_b_i
      ,sw_wd_i       => data_oe_wdata(7 downto 0)
      ,sw_rd_o       => data_oe_value_rdata
      ,sw_we_i       => data_oe_we
      ,sw_re_i       => data_oe_re
      ,sw_busy_o     => data_oe_rbusy
      ,hw_wd_i       => (others => '0')
      ,hw_rd_o       => sw2hw_o.data_oe.value
      ,hw_we_i       => '0'
      ,hw_sw_re_o    => sw2hw_o.data_oe.re
      ,hw_sw_we_o    => sw2hw_o.data_oe.we
      );

  --==================================
  -- Register    : data_in
  -- Description : GPIO Input
  -- Address     : 0x2
  -- Width       : 8
  -- Sw Access   : ro
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : Input Data of GPIO
  -- Width       : 8
  --==================================


  data_in_rcs     <= '1' when     (sig_raddr(GPIO_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(2,GPIO_ADDR_WIDTH))) else '0';
  data_in_re      <= sig_rcs and data_in_rcs and sig_re;
  data_in_rdata   <= (
    7 => data_in_value_rdata(7),
    6 => data_in_value_rdata(6),
    5 => data_in_value_rdata(5),
    4 => data_in_value_rdata(4),
    3 => data_in_value_rdata(3),
    2 => data_in_value_rdata(2),
    1 => data_in_value_rdata(1),
    0 => data_in_value_rdata(0),
    others => '0');

  data_in_wcs     <= '0';
  data_in_we      <= '0';
  data_in_wdata   <= (others=>'0');

  ins_data_in : entity work.csr_reg(rtl)
    generic map
      (WIDTH         => 8
      ,INIT          => "00000000"
      ,MODEL         => "ro"
      )
    port map
      (clk_i         => clk_i
      ,arst_b_i      => arst_b_i
      ,sw_wd_i       => data_in_wdata(7 downto 0)
      ,sw_rd_o       => data_in_value_rdata
      ,sw_we_i       => data_in_we
      ,sw_re_i       => data_in_re
      ,sw_busy_o     => data_in_rbusy
      ,hw_wd_i       => hw2sw_i.data_in.value
      ,hw_rd_o       => sw2hw_o.data_in.value
      ,hw_we_i       => hw2sw_i.data_in.we
      ,hw_sw_re_o    => sw2hw_o.data_in.re
      ,hw_sw_we_o      => open
      );

  --==================================
  -- Register    : data_out
  -- Description : GPIO Output
  -- Address     : 0x3
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : Output Data of GPIO
  -- Width       : 8
  --==================================


  data_out_rcs     <= '1' when     (sig_raddr(GPIO_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(3,GPIO_ADDR_WIDTH))) else '0';
  data_out_re      <= sig_rcs and data_out_rcs and sig_re;
  data_out_rdata   <= (
    7 => data_out_value_rdata(7),
    6 => data_out_value_rdata(6),
    5 => data_out_value_rdata(5),
    4 => data_out_value_rdata(4),
    3 => data_out_value_rdata(3),
    2 => data_out_value_rdata(2),
    1 => data_out_value_rdata(1),
    0 => data_out_value_rdata(0),
    others => '0');

  data_out_wcs     <= '1' when     (sig_waddr(GPIO_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(0,GPIO_ADDR_WIDTH))) or (sig_waddr(GPIO_ADDR_WIDTH-1 downto 0) = std_logic_vector(to_unsigned(3,GPIO_ADDR_WIDTH))) else '0';
  data_out_we      <= sig_wcs and data_out_wcs and sig_we;
  data_out_wdata   <= sig_wdata;

  ins_data_out : entity work.csr_reg(rtl)
    generic map
      (WIDTH         => 8
      ,INIT          => "00000000"
      ,MODEL         => "rw"
      )
    port map
      (clk_i         => clk_i
      ,arst_b_i      => arst_b_i
      ,sw_wd_i       => data_out_wdata(7 downto 0)
      ,sw_rd_o       => data_out_value_rdata
      ,sw_we_i       => data_out_we
      ,sw_re_i       => data_out_re
      ,sw_busy_o     => data_out_rbusy
      ,hw_wd_i       => (others => '0')
      ,hw_rd_o       => sw2hw_o.data_out.value
      ,hw_we_i       => '0'
      ,hw_sw_re_o    => sw2hw_o.data_out.re
      ,hw_sw_we_o    => sw2hw_o.data_out.we
      );

  sig_rbusy <= 
    data_rbusy when data_rcs = '1' else
    data_oe_rbusy when data_oe_rcs = '1' else
    data_in_rbusy when data_in_rcs = '1' else
    data_out_rbusy when data_out_rcs = '1' else
    '0'; -- Bad Address, no busy
  sig_rdata <= 
    data_rdata when data_rcs = '1' else
    data_oe_rdata when data_oe_rcs = '1' else
    data_in_rdata when data_in_rcs = '1' else
    data_out_rdata when data_out_rcs = '1' else
    (others => '0'); -- Bad Address, return 0
end architecture rtl;
