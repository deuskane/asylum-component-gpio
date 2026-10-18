-------------------------------------------------------------------------------
-- Title      : GPIO_top
-- Project    : GPIO
-------------------------------------------------------------------------------
-- File       : GPIO_top.vhd
-- Author     : Mathieu Rosiere
-------------------------------------------------------------------------------
-- Description:
-- Toplevel of the default target (elaboration / synthesis check) :
-- sbi_GPIO and sbi_GPIO_irq with flat and constrained ports (the SBI ports
-- of the wrappers are unconstrained and cannot be at the top of a design).
-------------------------------------------------------------------------------
-- Copyright (c) 2026
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-10-17  1.0      mrosiere Created
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
library asylum;
use     asylum.sbi_pkg.all;
use     asylum.GPIO_pkg.all;
use     asylum.GPIO_csr_pkg.all;
use     asylum.GPIO_irq_csr_pkg.all;

entity GPIO_top is
  generic
    (NB_IO            : natural                      := 8
    ;DATA_OE_INIT     : std_logic_vector(7 downto 0) := x"00"
    ;IRQ_POSEDGE      : std_logic_vector(7 downto 0) := x"FF"
    ;IRQ_NEGEDGE      : std_logic_vector(7 downto 0) := x"FF"
    );
  port
    (clk_i            : in  std_logic
    ;cke_i            : in  std_logic
    ;arstn_i          : in  std_logic

    -- sbi_GPIO
    ;gpio_cs_i        : in  std_logic
    ;gpio_re_i        : in  std_logic
    ;gpio_we_i        : in  std_logic
    ;gpio_addr_i      : in  std_logic_vector(GPIO_ADDR_WIDTH-1 downto 0)
    ;gpio_wdata_i     : in  std_logic_vector(GPIO_DATA_WIDTH-1 downto 0)
    ;gpio_ready_o     : out std_logic
    ;gpio_rdata_o     : out std_logic_vector(GPIO_DATA_WIDTH-1 downto 0)
    ;gpio_data_i      : in  std_logic_vector(NB_IO-1 downto 0)
    ;gpio_data_o      : out std_logic_vector(NB_IO-1 downto 0)
    ;gpio_data_oe_o   : out std_logic_vector(NB_IO-1 downto 0)

    -- sbi_GPIO_irq
    ;irq_cs_i         : in  std_logic
    ;irq_re_i         : in  std_logic
    ;irq_we_i         : in  std_logic
    ;irq_addr_i       : in  std_logic_vector(GPIO_IRQ_ADDR_WIDTH-1 downto 0)
    ;irq_wdata_i      : in  std_logic_vector(GPIO_IRQ_DATA_WIDTH-1 downto 0)
    ;irq_ready_o      : out std_logic
    ;irq_rdata_o      : out std_logic_vector(GPIO_IRQ_DATA_WIDTH-1 downto 0)
    ;irq_data_i       : in  std_logic_vector(NB_IO-1 downto 0)
    ;irq_data_o       : out std_logic_vector(NB_IO-1 downto 0)
    ;irq_data_oe_o    : out std_logic_vector(NB_IO-1 downto 0)
    ;irq_it_o         : out std_logic
    );
end entity GPIO_top;

architecture rtl of GPIO_top is

  signal gpio_sbi_ini : sbi_ini_t(addr (GPIO_ADDR_WIDTH-1 downto 0),
                                  wdata(GPIO_DATA_WIDTH-1 downto 0));
  signal gpio_sbi_tgt : sbi_tgt_t(rdata(GPIO_DATA_WIDTH-1 downto 0));

  signal irq_sbi_ini  : sbi_ini_t(addr (GPIO_IRQ_ADDR_WIDTH-1 downto 0),
                                  wdata(GPIO_IRQ_DATA_WIDTH-1 downto 0));
  signal irq_sbi_tgt  : sbi_tgt_t(rdata(GPIO_IRQ_DATA_WIDTH-1 downto 0));

begin

  -----------------------------------------------------------------------------
  -- sbi_GPIO
  -----------------------------------------------------------------------------
  gpio_sbi_ini.cs    <= gpio_cs_i;
  gpio_sbi_ini.re    <= gpio_re_i;
  gpio_sbi_ini.we    <= gpio_we_i;
  gpio_sbi_ini.addr  <= gpio_addr_i;
  gpio_sbi_ini.wdata <= gpio_wdata_i;
  gpio_ready_o       <= gpio_sbi_tgt.ready;
  gpio_rdata_o       <= gpio_sbi_tgt.rdata;

  ins_sbi_GPIO : sbi_GPIO
    generic map
    (NAME             => "GPIO"
    ,NB_IO            => NB_IO
    ,DATA_OE_INIT     => DATA_OE_INIT
    )
    port map
    (clk_i            => clk_i
    ,cke_i            => cke_i
    ,arstn_i          => arstn_i
    ,sbi_ini_i        => gpio_sbi_ini
    ,sbi_tgt_o        => gpio_sbi_tgt
    ,data_i           => gpio_data_i
    ,data_o           => gpio_data_o
    ,data_oe_o        => gpio_data_oe_o
    ,it_o             => open
    );

  -----------------------------------------------------------------------------
  -- sbi_GPIO_irq
  -----------------------------------------------------------------------------
  irq_sbi_ini.cs     <= irq_cs_i;
  irq_sbi_ini.re     <= irq_re_i;
  irq_sbi_ini.we     <= irq_we_i;
  irq_sbi_ini.addr   <= irq_addr_i;
  irq_sbi_ini.wdata  <= irq_wdata_i;
  irq_ready_o        <= irq_sbi_tgt.ready;
  irq_rdata_o        <= irq_sbi_tgt.rdata;

  ins_sbi_GPIO_irq : sbi_GPIO_irq
    generic map
    (NAME             => "GPIO_irq"
    ,NB_IO            => NB_IO
    ,DATA_OE_INIT     => DATA_OE_INIT
    ,IRQ_POSEDGE      => IRQ_POSEDGE
    ,IRQ_NEGEDGE      => IRQ_NEGEDGE
    )
    port map
    (clk_i            => clk_i
    ,cke_i            => cke_i
    ,arstn_i          => arstn_i
    ,sbi_ini_i        => irq_sbi_ini
    ,sbi_tgt_o        => irq_sbi_tgt
    ,data_i           => irq_data_i
    ,data_o           => irq_data_o
    ,data_oe_o        => irq_data_oe_o
    ,it_o             => irq_it_o
    );

end architecture rtl;
