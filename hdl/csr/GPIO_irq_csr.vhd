-- Generated VHDL Module for GPIO_irq


library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;

library asylum;
use     asylum.GPIO_irq_csr_pkg.ALL;
library asylum;
use     asylum.csr_pkg.ALL;
library asylum;
use     asylum.sbi_pkg.all;

--==================================
-- Module      : GPIO_irq
-- Description : CSR for General Purpose I/O
-- Width       : 8
--==================================
entity GPIO_irq_registers is
  generic (
    MODULE_NAME :  string := "" -- Name of the module
   ;DATA_OE_INIT : std_logic_vector -- Direction of the IO after a reset
  );
  port (
    -- Clock and Reset
    clk_i      : in  std_logic
   ;arst_b_i   : in  std_logic
    -- Bus
   ;sbi_ini_i  : in  sbi_ini_t
   ;sbi_tgt_o  : out sbi_tgt_t
    -- CSR
   ;sw2hw_o    : out GPIO_irq_sw2hw_t
   ;hw2sw_i    : in  GPIO_irq_hw2sw_t
  );
end entity GPIO_irq_registers;

architecture rtl of GPIO_irq_registers is

  signal   sig_wcs   : std_logic;
  signal   sig_we    : std_logic;
  signal   sig_waddr : unsigned(GPIO_irq_ADDR_WIDTH-1 downto 0);
  signal   sig_wdata : std_logic_vector(sbi_ini_i.wdata'length-1 downto 0);
  signal   sig_wbusy : std_logic;

  signal   sig_rcs   : std_logic;
  signal   sig_re    : std_logic;
  signal   sig_raddr : unsigned(GPIO_irq_ADDR_WIDTH-1 downto 0);
  signal   sig_rdata : std_logic_vector(sbi_tgt_o.rdata'length-1 downto 0);
  signal   sig_rbusy : std_logic;

  signal   sig_busy  : std_logic;

  function INIT_isr
    return std_logic_vector is
    variable tmp : std_logic_vector(1-1 downto 0);
  begin  -- function INIT_isr
    tmp(0 downto 0) := "0"; -- value
    return tmp;
  end function INIT_isr;

  signal   isr_wcs       : std_logic;
  signal   isr_we        : std_logic;
  signal   isr_wdata     : std_logic_vector(8-1 downto 0);
  signal   isr_wdata_sw  : std_logic_vector(1-1 downto 0);
  signal   isr_wdata_hw  : std_logic_vector(1-1 downto 0);
  signal   isr_wbusy     : std_logic;

  signal   isr_rcs       : std_logic;
  signal   isr_re        : std_logic;
  signal   isr_rdata     : std_logic_vector(8-1 downto 0);
  signal   isr_rdata_sw  : std_logic_vector(1-1 downto 0);
  signal   isr_rdata_hw  : std_logic_vector(1-1 downto 0);
  signal   isr_rbusy     : std_logic;

  function INIT_imr
    return std_logic_vector is
    variable tmp : std_logic_vector(1-1 downto 0);
  begin  -- function INIT_imr
    tmp(0 downto 0) := "0"; -- enable
    return tmp;
  end function INIT_imr;

  signal   imr_wcs       : std_logic;
  signal   imr_we        : std_logic;
  signal   imr_wdata     : std_logic_vector(8-1 downto 0);
  signal   imr_wdata_sw  : std_logic_vector(1-1 downto 0);
  signal   imr_wdata_hw  : std_logic_vector(1-1 downto 0);
  signal   imr_wbusy     : std_logic;

  signal   imr_rcs       : std_logic;
  signal   imr_re        : std_logic;
  signal   imr_rdata     : std_logic_vector(8-1 downto 0);
  signal   imr_rdata_sw  : std_logic_vector(1-1 downto 0);
  signal   imr_rdata_hw  : std_logic_vector(1-1 downto 0);
  signal   imr_rbusy     : std_logic;

  function INIT_data
    return std_logic_vector is
    variable tmp : std_logic_vector(8-1 downto 0);
  begin  -- function INIT_data
    tmp(7 downto 0) := "00000000"; -- value
    return tmp;
  end function INIT_data;

  signal   data_wcs       : std_logic;
  signal   data_we        : std_logic;
  signal   data_wdata     : std_logic_vector(8-1 downto 0);
  signal   data_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   data_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   data_wbusy     : std_logic;

  signal   data_rcs       : std_logic;
  signal   data_re        : std_logic;
  signal   data_rdata     : std_logic_vector(8-1 downto 0);
  signal   data_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   data_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   data_rbusy     : std_logic;

  function INIT_data_oe
    return std_logic_vector is
    variable tmp : std_logic_vector(8-1 downto 0);
  begin  -- function INIT_data_oe
    tmp(7 downto 0) := DATA_OE_INIT; -- value
    return tmp;
  end function INIT_data_oe;

  signal   data_oe_wcs       : std_logic;
  signal   data_oe_we        : std_logic;
  signal   data_oe_wdata     : std_logic_vector(8-1 downto 0);
  signal   data_oe_wdata_sw  : std_logic_vector(8-1 downto 0);
  signal   data_oe_wdata_hw  : std_logic_vector(8-1 downto 0);
  signal   data_oe_wbusy     : std_logic;

  signal   data_oe_rcs       : std_logic;
  signal   data_oe_re        : std_logic;
  signal   data_oe_rdata     : std_logic_vector(8-1 downto 0);
  signal   data_oe_rdata_sw  : std_logic_vector(8-1 downto 0);
  signal   data_oe_rdata_hw  : std_logic_vector(8-1 downto 0);
  signal   data_oe_rbusy     : std_logic;

begin  -- architecture rtl

  -- Interface 
  sig_wcs   <= sbi_ini_i.cs;
  sig_we    <= sbi_ini_i.we;
  sig_waddr <= unsigned(sbi_ini_i.addr(GPIO_irq_ADDR_WIDTH-1 downto 0));
  sig_wdata <= sbi_ini_i.wdata;

  sig_rcs   <= sbi_ini_i.cs;
  sig_re    <= sbi_ini_i.re;
  sig_raddr <= unsigned(sbi_ini_i.addr(GPIO_irq_ADDR_WIDTH-1 downto 0));
  sbi_tgt_o.rdata <= sig_rdata;
  sbi_tgt_o.ready <= not sig_busy;

  sig_busy  <= sig_wbusy when sig_we = '1' else
               sig_rbusy when sig_re = '1' else
               '0';

  gen_isr: if (True)
  generate
  --==================================
  -- Register    : isr
  -- Description : Interruption Status Register
  -- Address     : 0x0
  -- Width       : 1
  -- Sw Access   : rw1c
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : 0: interrupt is inactive, 1: interrupt is active
  -- Width       : 1
  --==================================


    isr_rcs     <= '1' when (sig_raddr = GPIO_irq_ISR) else '0';
    isr_re      <= sig_rcs and sig_re and isr_rcs;
    isr_rdata   <= (
      0 => isr_rdata_sw(0), -- value(0)
      others => '0');

    isr_wcs     <= '1' when       (sig_waddr = GPIO_irq_ISR)   else '0';
    isr_we      <= sig_wcs and sig_we and isr_wcs;
    isr_wdata   <= sig_wdata;
    isr_wdata_sw(0 downto 0) <= isr_wdata(0 downto 0); -- value
    isr_wdata_hw(0 downto 0) <= hw2sw_i.isr.value; -- value
    sw2hw_o.isr.value <= isr_rdata_hw(0 downto 0); -- value

    ins_isr : csr_reg
      generic map
        (WIDTH         => 1
        ,INIT          => INIT_isr
        ,MODEL         => "rw1c"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => isr_wdata_sw
        ,sw_rd_o       => isr_rdata_sw
        ,sw_we_i       => isr_we
        ,sw_re_i       => isr_re
        ,sw_rbusy_o    => isr_rbusy
        ,sw_wbusy_o    => isr_wbusy
        ,hw_wd_i       => isr_wdata_hw
        ,hw_rd_o       => isr_rdata_hw
        ,hw_we_i       => hw2sw_i.isr.we
        ,hw_sw_re_o    => sw2hw_o.isr.re
        ,hw_sw_we_o    => sw2hw_o.isr.we
        );

  end generate gen_isr;

  gen_isr_b: if not (True)
  generate
    isr_rcs     <= '0';
    isr_rbusy   <= '0';
    isr_rdata   <= (others => '0');
    isr_wcs      <= '0';
    isr_wbusy    <= '0';
    sw2hw_o.isr.value <= "0";
    sw2hw_o.isr.re <= '0';
    sw2hw_o.isr.we <= '0';
  end generate gen_isr_b;

  gen_imr: if (True)
  generate
  --==================================
  -- Register    : imr
  -- Description : Interruption Mask Register
  -- Address     : 0x1
  -- Width       : 1
  -- Sw Access   : rw
  -- Hw Access   : ro
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : enable
  -- Description : 0: interrupt is disable, 1: interrupt is enable
  -- Width       : 1
  --==================================


    imr_rcs     <= '1' when (sig_raddr = GPIO_irq_IMR) else '0';
    imr_re      <= sig_rcs and sig_re and imr_rcs;
    imr_rdata   <= (
      0 => imr_rdata_sw(0), -- enable(0)
      others => '0');

    imr_wcs     <= '1' when       (sig_waddr = GPIO_irq_IMR)   else '0';
    imr_we      <= sig_wcs and sig_we and imr_wcs;
    imr_wdata   <= sig_wdata;
    imr_wdata_sw(0 downto 0) <= imr_wdata(0 downto 0); -- enable
    sw2hw_o.imr.enable <= imr_rdata_hw(0 downto 0); -- enable

    ins_imr : csr_reg
      generic map
        (WIDTH         => 1
        ,INIT          => INIT_imr
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => imr_wdata_sw
        ,sw_rd_o       => imr_rdata_sw
        ,sw_we_i       => imr_we
        ,sw_re_i       => imr_re
        ,sw_rbusy_o    => imr_rbusy
        ,sw_wbusy_o    => imr_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => imr_rdata_hw
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.imr.re
        ,hw_sw_we_o    => sw2hw_o.imr.we
        );

  end generate gen_imr;

  gen_imr_b: if not (True)
  generate
    imr_rcs     <= '0';
    imr_rbusy   <= '0';
    imr_rdata   <= (others => '0');
    imr_wcs      <= '0';
    imr_wbusy    <= '0';
    sw2hw_o.imr.enable <= "0";
    sw2hw_o.imr.re <= '0';
    sw2hw_o.imr.we <= '0';
  end generate gen_imr_b;

  gen_data: if (True)
  generate
  --==================================
  -- Register    : data
  -- Description : data
  -- Address     : 0x2
  -- Width       : 8
  -- Sw Access   : rw
  -- Hw Access   : rw
  -- Hw Type     : reg
  --==================================
  --==================================
  -- Field       : value
  -- Description : Data with data_oe with mask apply
  -- Width       : 8
  --==================================


    data_rcs     <= '1' when (sig_raddr = GPIO_irq_DATA) else '0';
    data_re      <= sig_rcs and sig_re and data_rcs;
    data_rdata   <= (
      0 => data_rdata_sw(0), -- value(0)
      1 => data_rdata_sw(1), -- value(1)
      2 => data_rdata_sw(2), -- value(2)
      3 => data_rdata_sw(3), -- value(3)
      4 => data_rdata_sw(4), -- value(4)
      5 => data_rdata_sw(5), -- value(5)
      6 => data_rdata_sw(6), -- value(6)
      7 => data_rdata_sw(7), -- value(7)
      others => '0');

    data_wcs     <= '1' when       (sig_waddr = GPIO_irq_DATA)   else '0';
    data_we      <= sig_wcs and sig_we and data_wcs;
    data_wdata   <= sig_wdata;
    data_wdata_sw(7 downto 0) <= data_wdata(7 downto 0); -- value
    data_wdata_hw(7 downto 0) <= hw2sw_i.data.value; -- value
    sw2hw_o.data.value <= data_rdata_hw(7 downto 0); -- value

    ins_data : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_data
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => data_wdata_sw
        ,sw_rd_o       => data_rdata_sw
        ,sw_we_i       => data_we
        ,sw_re_i       => data_re
        ,sw_rbusy_o    => data_rbusy
        ,sw_wbusy_o    => data_wbusy
        ,hw_wd_i       => data_wdata_hw
        ,hw_rd_o       => data_rdata_hw
        ,hw_we_i       => hw2sw_i.data.we
        ,hw_sw_re_o    => sw2hw_o.data.re
        ,hw_sw_we_o    => sw2hw_o.data.we
        );

  end generate gen_data;

  gen_data_b: if not (True)
  generate
    data_rcs     <= '0';
    data_rbusy   <= '0';
    data_rdata   <= (others => '0');
    data_wcs      <= '0';
    data_wbusy    <= '0';
    sw2hw_o.data.value <= "00000000";
    sw2hw_o.data.re <= '0';
    sw2hw_o.data.we <= '0';
  end generate gen_data_b;

  gen_data_oe: if (True)
  generate
  --==================================
  -- Register    : data_oe
  -- Description : GPIO Direction
  -- Address     : 0x3
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


    data_oe_rcs     <= '1' when (sig_raddr = GPIO_irq_DATA_OE) else '0';
    data_oe_re      <= sig_rcs and sig_re and data_oe_rcs;
    data_oe_rdata   <= (
      0 => data_oe_rdata_sw(0), -- value(0)
      1 => data_oe_rdata_sw(1), -- value(1)
      2 => data_oe_rdata_sw(2), -- value(2)
      3 => data_oe_rdata_sw(3), -- value(3)
      4 => data_oe_rdata_sw(4), -- value(4)
      5 => data_oe_rdata_sw(5), -- value(5)
      6 => data_oe_rdata_sw(6), -- value(6)
      7 => data_oe_rdata_sw(7), -- value(7)
      others => '0');

    data_oe_wcs     <= '1' when       (sig_waddr = GPIO_irq_DATA_OE)   else '0';
    data_oe_we      <= sig_wcs and sig_we and data_oe_wcs;
    data_oe_wdata   <= sig_wdata;
    data_oe_wdata_sw(7 downto 0) <= data_oe_wdata(7 downto 0); -- value
    sw2hw_o.data_oe.value <= data_oe_rdata_hw(7 downto 0); -- value

    ins_data_oe : csr_reg
      generic map
        (WIDTH         => 8
        ,INIT          => INIT_data_oe
        ,MODEL         => "rw"
        )
      port map
        (clk_i         => clk_i
        ,arst_b_i      => arst_b_i
        ,sw_wd_i       => data_oe_wdata_sw
        ,sw_rd_o       => data_oe_rdata_sw
        ,sw_we_i       => data_oe_we
        ,sw_re_i       => data_oe_re
        ,sw_rbusy_o    => data_oe_rbusy
        ,sw_wbusy_o    => data_oe_wbusy
        ,hw_wd_i       => (others => '0')
        ,hw_rd_o       => data_oe_rdata_hw
        ,hw_we_i       => '0'
        ,hw_sw_re_o    => sw2hw_o.data_oe.re
        ,hw_sw_we_o    => sw2hw_o.data_oe.we
        );

  end generate gen_data_oe;

  gen_data_oe_b: if not (True)
  generate
    data_oe_rcs     <= '0';
    data_oe_rbusy   <= '0';
    data_oe_rdata   <= (others => '0');
    data_oe_wcs      <= '0';
    data_oe_wbusy    <= '0';
    sw2hw_o.data_oe.value <= DATA_OE_INIT;
    sw2hw_o.data_oe.re <= '0';
    sw2hw_o.data_oe.we <= '0';
  end generate gen_data_oe_b;

  sig_wbusy <= 
    isr_wbusy when isr_wcs = '1' else
    imr_wbusy when imr_wcs = '1' else
    data_wbusy when data_wcs = '1' else
    data_oe_wbusy when data_oe_wcs = '1' else
    '0'; -- Bad Address, no busy
  sig_rbusy <= 
    isr_rbusy when isr_rcs = '1' else
    imr_rbusy when imr_rcs = '1' else
    data_rbusy when data_rcs = '1' else
    data_oe_rbusy when data_oe_rcs = '1' else
    '0'; -- Bad Address, no busy
  sig_rdata <= 
    isr_rdata when isr_rcs = '1' else
    imr_rdata when imr_rcs = '1' else
    data_rdata when data_rcs = '1' else
    data_oe_rdata when data_oe_rcs = '1' else
    (others => '0'); -- Bad Address, return 0

  gen_tgt_info_name : if MODULE_NAME = ""
  generate
    sbi_tgt_o.info.name <= to_sbi_name("GPIO_irq");
  else generate
    sbi_tgt_o.info.name <= to_sbi_name(MODULE_NAME);
  end generate;
end architecture rtl;
