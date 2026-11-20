-------------------------------------------------------------------------------
-- Title      : sbi_GPIO_wrapper
-- Project    : Asylum
-------------------------------------------------------------------------------
-- File       : sbi_GPIO_wrapper.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description:
-- Wrapper (lint_ghdl, lint_ghdl_synth_gpio_*, syn_gpio_*) : sbi_GPIO with
-- flat and constrained ports (its SBI ports are unconstrained and its
-- DATA_OE_INIT generic has no default : it cannot be a synthesis top). SBI
-- address / data width : SBI_ADDR_WIDTH / SBI_DATA_WIDTH (NAME is only in
-- sbi_tgt.info, not connected). DATA_OE_INIT is 8-bit wide (CSR width).
-- sbi_GPIO_irq has its own wrapper, sbi_GPIO_irq_wrapper.
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-20  1.0      mrosiere Created
-- 2026-10-24  1.1      mrosiere Was sbi_GPIO_synth_top, library asylum
-- 2026-11-20  2.0      mrosiere sbi_GPIO only, sbi_GPIO_irq in
--                               sbi_GPIO_irq_wrapper
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
library asylum;
use     asylum.sbi_pkg.all;
use     asylum.GPIO_csr_pkg.all;

entity sbi_GPIO_wrapper is
  generic (
    NB_IO           : natural := 8;
    DATA_OE_INIT    : std_logic_vector(GPIO_DATA_WIDTH-1 downto 0) := (others => '0')
  );
  port (
    clk_i           : in  std_logic;
    cke_i           : in  std_logic;
    arstn_i         : in  std_logic;

    -- Bus
    cs_i            : in  std_logic;
    re_i            : in  std_logic;
    we_i            : in  std_logic;
    addr_i          : in  std_logic_vector(SBI_ADDR_WIDTH-1 downto 0);
    wdata_i         : in  std_logic_vector(SBI_DATA_WIDTH-1 downto 0);
    ready_o         : out std_logic;
    rdata_o         : out std_logic_vector(SBI_DATA_WIDTH-1 downto 0);

    -- To/From IO
    data_i          : in  std_logic_vector(NB_IO-1 downto 0);
    data_o          : out std_logic_vector(NB_IO-1 downto 0);
    data_oe_o       : out std_logic_vector(NB_IO-1 downto 0);

    -- Interruption
    it_o            : out std_logic
  );
end entity sbi_GPIO_wrapper;

architecture rtl of sbi_GPIO_wrapper is

  signal sbi_ini  : sbi_ini_t(addr (SBI_ADDR_WIDTH-1 downto 0),
                              wdata(SBI_DATA_WIDTH-1 downto 0));
  signal sbi_tgt  : sbi_tgt_t(rdata(SBI_DATA_WIDTH-1 downto 0));

begin

  sbi_ini.cs    <= cs_i;
  sbi_ini.re    <= re_i;
  sbi_ini.we    <= we_i;
  sbi_ini.addr  <= addr_i;
  sbi_ini.wdata <= wdata_i;
  ready_o       <= sbi_tgt.ready;
  rdata_o       <= sbi_tgt.rdata;

  ins_sbi_GPIO : entity asylum.sbi_GPIO
    generic map (
      NB_IO           => NB_IO,
      DATA_OE_INIT    => DATA_OE_INIT
    )
    port map (
      clk_i           => clk_i,
      cke_i           => cke_i,
      arstn_i         => arstn_i,
      sbi_ini_i       => sbi_ini,
      sbi_tgt_o       => sbi_tgt,
      data_i          => data_i,
      data_o          => data_o,
      data_oe_o       => data_oe_o,
      it_o            => it_o
    );

end architecture rtl;
