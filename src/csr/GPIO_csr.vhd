-- Generated VHDL Module for GPIO


library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

library asylum;
use     asylum.GPIO_csr_pkg.ALL;

entity GPIO_registers is
  port (
    -- Clock and Reset
    clk_i      : in  std_logic;
    arst_b_i   : in  std_logic;
    -- Bus
    cs_i       : in    std_logic;
    re_i       : in    std_logic;
    we_i       : in    std_logic;
    addr_i     : in    std_logic_vector (2-1 downto 0);
    wdata_i    : in    std_logic_vector (8-1 downto 0);
    rdata_o    : out   std_logic_vector (8-1 downto 0);
    busy_o     : out   std_logic;
    -- CSR
    sw2hw_o    : out GPIO_sw2hw_t;
    hw2sw_i    : in  GPIO_hw2sw_t
  );
end entity GPIO_registers;

architecture rtl of GPIO_registers is

  constant SIZE_ADDR : integer := 2;
  signal   data_wcs   : std_logic;
  signal   data_rcs   : std_logic;
  signal   data_we    : std_logic;
  signal   data_re    : std_logic;
  signal   data_rdata : std_logic_vector(8-1 downto 0);
  signal   data_wdata : std_logic_vector(8-1 downto 0);
  signal   data_value_rdata : std_logic_vector(7 downto 0);

  signal   data_oe_wcs   : std_logic;
  signal   data_oe_rcs   : std_logic;
  signal   data_oe_we    : std_logic;
  signal   data_oe_re    : std_logic;
  signal   data_oe_rdata : std_logic_vector(8-1 downto 0);
  signal   data_oe_wdata : std_logic_vector(8-1 downto 0);
  signal   data_oe_value_rdata : std_logic_vector(7 downto 0);

  signal   data_in_wcs   : std_logic;
  signal   data_in_rcs   : std_logic;
  signal   data_in_we    : std_logic;
  signal   data_in_re    : std_logic;
  signal   data_in_rdata : std_logic_vector(8-1 downto 0);
  signal   data_in_wdata : std_logic_vector(8-1 downto 0);
  signal   data_in_value_rdata : std_logic_vector(7 downto 0);

  signal   data_out_wcs   : std_logic;
  signal   data_out_rcs   : std_logic;
  signal   data_out_we    : std_logic;
  signal   data_out_re    : std_logic;
  signal   data_out_rdata : std_logic_vector(8-1 downto 0);
  signal   data_out_wdata : std_logic_vector(8-1 downto 0);
  signal   data_out_value_rdata : std_logic_vector(7 downto 0);

begin  -- architecture rtl

  --==================================
  -- Register    : data
  -- Description : data - with data_oe mask apply
  -- Address     : 0x0
  -- Hw External : True
  --==================================

  data_rcs     <= '1' when     (addr_i = std_logic_vector(to_unsigned(0,SIZE_ADDR))) else '0';
  data_re      <= cs_i and data_rcs and re_i;
  data_rdata   <= (
    7 => data_value_rdata(7),
    6 => data_value_rdata(6),
    5 => data_value_rdata(5),
    4 => data_value_rdata(4),
    3 => data_value_rdata(3),
    2 => data_value_rdata(2),
    1 => data_value_rdata(1),
    0 => data_value_rdata(0),
    others => '0') when data_rcs = '1' else (others => '0');

  data_wcs     <= '0';
  data_we      <= '0';
  data_wdata   <= (others=>'0');

  -- Field       : data.value
  -- Description : Data with data_oe with mask apply
  data_value_rdata <= hw2sw_i.data.value;
  sw2hw_o.data.value <= data_wdata(7 downto 0);
  sw2hw_o.data.re <= data_re;

  --==================================
  -- Register    : data_oe
  -- Description : GPIO Direction
  -- Address     : 0x1
  -- Hw External : False
  --==================================

  data_oe_rcs     <= '1' when     (addr_i = std_logic_vector(to_unsigned(1,SIZE_ADDR))) else '0';
  data_oe_re      <= cs_i and data_oe_rcs and re_i;
  data_oe_rdata   <= (
    7 => data_oe_value_rdata(7),
    6 => data_oe_value_rdata(6),
    5 => data_oe_value_rdata(5),
    4 => data_oe_value_rdata(4),
    3 => data_oe_value_rdata(3),
    2 => data_oe_value_rdata(2),
    1 => data_oe_value_rdata(1),
    0 => data_oe_value_rdata(0),
    others => '0') when data_oe_rcs = '1' else (others => '0');

  data_oe_wcs     <= '1' when     (addr_i = std_logic_vector(to_unsigned(1,SIZE_ADDR))) else '0';
  data_oe_we      <= cs_i and data_oe_wcs and we_i;
  data_oe_wdata   <= wdata_i;

  -- Field       : data_oe.value
  -- Description : GPIO Direction : 0 input, 1 output
  ins_data_oe_value : entity work.csr_reg(rtl)
    generic map
      (WIDTH       => 8
      ,INIT        => "00000000"
      ,MODEL       => "rw"
      )
    port map
      (clk_i       => clk_i
      ,arst_b_i    => arst_b_i
      ,sw_wd_i     => data_oe_wdata(7 downto 0)
      ,sw_rd_o     => data_oe_value_rdata
      ,sw_we_i     => data_oe_we
      ,sw_re_i     => data_oe_re
      ,hw_wd_i     => (others => '0')
      ,hw_rd_o     => sw2hw_o.data_oe.value
      ,hw_we_i     => '0'
      ,hw_sw_re_o  => sw2hw_o.data_oe.re
      ,hw_sw_we_o  => sw2hw_o.data_oe.we
      );

  --==================================
  -- Register    : data_in
  -- Description : GPIO Input
  -- Address     : 0x2
  -- Hw External : False
  --==================================

  data_in_rcs     <= '1' when     (addr_i = std_logic_vector(to_unsigned(2,SIZE_ADDR))) else '0';
  data_in_re      <= cs_i and data_in_rcs and re_i;
  data_in_rdata   <= (
    7 => data_in_value_rdata(7),
    6 => data_in_value_rdata(6),
    5 => data_in_value_rdata(5),
    4 => data_in_value_rdata(4),
    3 => data_in_value_rdata(3),
    2 => data_in_value_rdata(2),
    1 => data_in_value_rdata(1),
    0 => data_in_value_rdata(0),
    others => '0') when data_in_rcs = '1' else (others => '0');

  data_in_wcs     <= '0';
  data_in_we      <= '0';
  data_in_wdata   <= (others=>'0');

  -- Field       : data_in.value
  -- Description : Input Data of GPIO
  ins_data_in_value : entity work.csr_reg(rtl)
    generic map
      (WIDTH       => 8
      ,INIT        => "00000000"
      ,MODEL       => "ro"
      )
    port map
      (clk_i       => clk_i
      ,arst_b_i    => arst_b_i
      ,sw_wd_i     => data_in_wdata(7 downto 0)
      ,sw_rd_o     => data_in_value_rdata
      ,sw_we_i     => data_in_we
      ,sw_re_i     => data_in_re
      ,hw_wd_i     => hw2sw_i.data_in.value
      ,hw_rd_o     => sw2hw_o.data_in.value
      ,hw_we_i     => hw2sw_i.data_in.we
      ,hw_sw_re_o  => sw2hw_o.data_in.re
      ,hw_sw_we_o  => open
      );

  --==================================
  -- Register    : data_out
  -- Description : GPIO Output
  -- Address     : 0x3
  -- Hw External : False
  --==================================

  data_out_rcs     <= '1' when     (addr_i = std_logic_vector(to_unsigned(3,SIZE_ADDR))) else '0';
  data_out_re      <= cs_i and data_out_rcs and re_i;
  data_out_rdata   <= (
    7 => data_out_value_rdata(7),
    6 => data_out_value_rdata(6),
    5 => data_out_value_rdata(5),
    4 => data_out_value_rdata(4),
    3 => data_out_value_rdata(3),
    2 => data_out_value_rdata(2),
    1 => data_out_value_rdata(1),
    0 => data_out_value_rdata(0),
    others => '0') when data_out_rcs = '1' else (others => '0');

  data_out_wcs     <= '1' when     (addr_i = std_logic_vector(to_unsigned(0,SIZE_ADDR))) or (addr_i = std_logic_vector(to_unsigned(3,SIZE_ADDR))) else '0';
  data_out_we      <= cs_i and data_out_wcs and we_i;
  data_out_wdata   <= wdata_i;

  -- Field       : data_out.value
  -- Description : Output Data of GPIO
  ins_data_out_value : entity work.csr_reg(rtl)
    generic map
      (WIDTH       => 8
      ,INIT        => "00000000"
      ,MODEL       => "rw"
      )
    port map
      (clk_i       => clk_i
      ,arst_b_i    => arst_b_i
      ,sw_wd_i     => data_out_wdata(7 downto 0)
      ,sw_rd_o     => data_out_value_rdata
      ,sw_we_i     => data_out_we
      ,sw_re_i     => data_out_re
      ,hw_wd_i     => (others => '0')
      ,hw_rd_o     => sw2hw_o.data_out.value
      ,hw_we_i     => '0'
      ,hw_sw_re_o  => sw2hw_o.data_out.re
      ,hw_sw_we_o  => sw2hw_o.data_out.we
      );

  busy_o  <= '0';
  rdata_o <= 
    data_rdata or
    data_oe_rdata or
    data_in_rdata or
    data_out_rdata;
end architecture rtl;
