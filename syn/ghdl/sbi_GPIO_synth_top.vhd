-------------------------------------------------------------------------------
-- Title      : sbi_GPIO_synth_top
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : sbi_GPIO_synth_top.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description:
-- Synthesis check top (lint_ghdl, lint_ghdl_synth) : sbi_GPIO and
-- sbi_GPIO_irq with flat and constrained ports (their SBI ports are
-- unconstrained and their DATA_OE_INIT / IRQ_* generics have no default :
-- they cannot be a synthesis top). SBI address / data width :
-- SBI_ADDR_WIDTH / SBI_DATA_WIDTH. NB_IO and DATA_OE_INIT are shared by the
-- two instances, IRQ_POSEDGE / IRQ_NEGEDGE go to sbi_GPIO_irq (NAME is only
-- in sbi_tgt.info, not connected). DATA_OE_INIT and IRQ_* are 8-bit wide
-- (CSR width) as in asylum-soc-picosoc.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-20  1.0      mrosiere Created
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
library asylum;
use     asylum.sbi_pkg.all;
use     asylum.GPIO_csr_pkg.all;
use     asylum.GPIO_irq_csr_pkg.all;

entity sbi_GPIO_synth_top is
  generic (
    NB_IO           : natural := 8;
    DATA_OE_INIT    : std_logic_vector(GPIO_DATA_WIDTH-1 downto 0)     := (others => '0');
    IRQ_POSEDGE     : std_logic_vector(GPIO_IRQ_DATA_WIDTH-1 downto 0) := (others => '1');
    IRQ_NEGEDGE     : std_logic_vector(GPIO_IRQ_DATA_WIDTH-1 downto 0) := (others => '1')
  );
  port (
    clk_i           : in  std_logic;
    cke_i           : in  std_logic;
    arstn_i         : in  std_logic;

    -- sbi_GPIO
    gpio_cs_i       : in  std_logic;
    gpio_re_i       : in  std_logic;
    gpio_we_i       : in  std_logic;
    gpio_addr_i     : in  std_logic_vector(SBI_ADDR_WIDTH-1 downto 0);
    gpio_wdata_i    : in  std_logic_vector(SBI_DATA_WIDTH-1 downto 0);
    gpio_ready_o    : out std_logic;
    gpio_rdata_o    : out std_logic_vector(SBI_DATA_WIDTH-1 downto 0);
    gpio_data_i     : in  std_logic_vector(NB_IO-1 downto 0);
    gpio_data_o     : out std_logic_vector(NB_IO-1 downto 0);
    gpio_data_oe_o  : out std_logic_vector(NB_IO-1 downto 0);
    gpio_it_o       : out std_logic;

    -- sbi_GPIO_irq
    irq_cs_i        : in  std_logic;
    irq_re_i        : in  std_logic;
    irq_we_i        : in  std_logic;
    irq_addr_i      : in  std_logic_vector(SBI_ADDR_WIDTH-1 downto 0);
    irq_wdata_i     : in  std_logic_vector(SBI_DATA_WIDTH-1 downto 0);
    irq_ready_o     : out std_logic;
    irq_rdata_o     : out std_logic_vector(SBI_DATA_WIDTH-1 downto 0);
    irq_data_i      : in  std_logic_vector(NB_IO-1 downto 0);
    irq_data_o      : out std_logic_vector(NB_IO-1 downto 0);
    irq_data_oe_o   : out std_logic_vector(NB_IO-1 downto 0);
    irq_it_o        : out std_logic
  );
end entity sbi_GPIO_synth_top;

architecture rtl of sbi_GPIO_synth_top is

  signal gpio_sbi_ini  : sbi_ini_t(addr (SBI_ADDR_WIDTH-1 downto 0),
                                   wdata(SBI_DATA_WIDTH-1 downto 0));
  signal gpio_sbi_tgt  : sbi_tgt_t(rdata(SBI_DATA_WIDTH-1 downto 0));
  signal irq_sbi_ini   : sbi_ini_t(addr (SBI_ADDR_WIDTH-1 downto 0),
                                   wdata(SBI_DATA_WIDTH-1 downto 0));
  signal irq_sbi_tgt   : sbi_tgt_t(rdata(SBI_DATA_WIDTH-1 downto 0));

begin

  gpio_sbi_ini.cs    <= gpio_cs_i;
  gpio_sbi_ini.re    <= gpio_re_i;
  gpio_sbi_ini.we    <= gpio_we_i;
  gpio_sbi_ini.addr  <= gpio_addr_i;
  gpio_sbi_ini.wdata <= gpio_wdata_i;
  gpio_ready_o       <= gpio_sbi_tgt.ready;
  gpio_rdata_o       <= gpio_sbi_tgt.rdata;

  ins_sbi_GPIO : entity asylum.sbi_GPIO
    generic map (
      NB_IO           => NB_IO,
      DATA_OE_INIT    => DATA_OE_INIT
    )
    port map (
      clk_i           => clk_i,
      cke_i           => cke_i,
      arstn_i         => arstn_i,
      sbi_ini_i       => gpio_sbi_ini,
      sbi_tgt_o       => gpio_sbi_tgt,
      data_i          => gpio_data_i,
      data_o          => gpio_data_o,
      data_oe_o       => gpio_data_oe_o,
      it_o            => gpio_it_o
    );

  irq_sbi_ini.cs     <= irq_cs_i;
  irq_sbi_ini.re     <= irq_re_i;
  irq_sbi_ini.we     <= irq_we_i;
  irq_sbi_ini.addr   <= irq_addr_i;
  irq_sbi_ini.wdata  <= irq_wdata_i;
  irq_ready_o        <= irq_sbi_tgt.ready;
  irq_rdata_o        <= irq_sbi_tgt.rdata;

  ins_sbi_GPIO_irq : entity asylum.sbi_GPIO_irq
    generic map (
      NB_IO           => NB_IO,
      DATA_OE_INIT    => DATA_OE_INIT,
      IRQ_POSEDGE     => IRQ_POSEDGE,
      IRQ_NEGEDGE     => IRQ_NEGEDGE
    )
    port map (
      clk_i           => clk_i,
      cke_i           => cke_i,
      arstn_i         => arstn_i,
      sbi_ini_i       => irq_sbi_ini,
      sbi_tgt_o       => irq_sbi_tgt,
      data_i          => irq_data_i,
      data_o          => irq_data_o,
      data_oe_o       => irq_data_oe_o,
      it_o            => irq_it_o
    );

end architecture rtl;
