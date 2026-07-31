-------------------------------------------------------------------------------
-- Title      : GPIO
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : GPIO_irq_core.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2026-07-26
-- Last update: 2026-07-26
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- It's a GPIO component
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2026-07-26  0.1      mrosiere Created
-------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.numeric_std.ALL;
library asylum;
use     asylum.GIC_pkg.all;
use     asylum.GPIO_irq_csr_pkg.ALL;

entity GPIO_irq_core is
  generic
   (NB_IO            : natural:=8        -- Number of IO. Must be <= SIZE_DATA
   ;IRQ_POSEDGE      : std_logic_vector  -- Interrupt on rising edge
   ;IRQ_NEGEDGE      : std_logic_vector  -- Interrupt on falling edge
   );
  port
   (clk_i            : in    std_logic
   ;cke_i            : in    std_logic
   ;arstn_i          : in    std_logic -- asynchronous reset

    -- To/From IO
   ;data_i           : in    std_logic_vector (NB_IO-1     downto 0)
   ;data_o           : out   std_logic_vector (NB_IO-1     downto 0)
   ;data_oe_o        : out   std_logic_vector (NB_IO-1     downto 0)
    
   ;sw2hw_i          : in    GPIO_irq_sw2hw_t
   ;hw2sw_o          : out   GPIO_irq_hw2sw_t

   ;it_o             : out   std_logic
    );
end GPIO_irq_core;

architecture rtl of GPIO_irq_core is

  -----------------------------------------------------------------------------
  -- Local parameters
  -----------------------------------------------------------------------------
  constant CSR_DATA_WIDTH : natural := hw2sw_o.data.value'length;
  -----------------------------------------------------------------------------
  -- Signal
  -----------------------------------------------------------------------------
  signal data_in         : std_logic_vector (CSR_DATA_WIDTH-1 downto 0);
  signal data_in_posedge : std_logic_vector (CSR_DATA_WIDTH-1 downto 0);
  signal data_in_negedge : std_logic_vector (CSR_DATA_WIDTH-1 downto 0);

  signal gic_it          : std_logic_vector (CSR_DATA_WIDTH-1 downto 0);

  signal data_in_r       : std_logic_vector (CSR_DATA_WIDTH-1 downto 0);
  signal data_out_r      : std_logic_vector (NB_IO         -1 downto 0);
  signal data_out        : std_logic_vector (CSR_DATA_WIDTH-1 downto 0);
begin

  -----------------------------------------------------------------------------
  -- Data I/O
  -----------------------------------------------------------------------------
  -- transfer the input data to the internal signal with the same width as the CSR data width
  data_in               <= std_logic_vector(resize(unsigned(data_i    ), CSR_DATA_WIDTH));
  data_out              <= std_logic_vector(resize(unsigned(data_out_r), CSR_DATA_WIDTH));

  data_o                <= data_out_r;
  data_oe_o             <= sw2hw_i.data_oe.value(data_oe_o'range);

  hw2sw_o.data.value    <= ((data_out and     sw2hw_i.data_oe .value) or
                            (data_in  and not sw2hw_i.data_oe .value));
  hw2sw_o.data.we       <= '1';

  -----------------------------------------------------------------------------
  -- Data output register
  -----------------------------------------------------------------------------
  process(clk_i, arstn_i)
  begin
    if arstn_i = '0' 
    then
      data_out_r <= (others => '0');
    elsif rising_edge(clk_i)
    then
      if (sw2hw_i.data.we = '1') 
      then
        data_out_r <= sw2hw_i.data.value(data_out_r'range);
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Data input register
  -----------------------------------------------------------------------------
  process(clk_i)
  begin
    if rising_edge(clk_i)
    then
      data_in_r <= data_in;
    end if;
  end process;

  ---------------------------------------------
  -- Interruption
  ---------------------------------------------
  data_in_posedge       <=     data_in and not data_in_r; -- Rising  edge detection
  data_in_negedge       <= not data_in and     data_in_r; -- Falling edge detection

  gic_it                <= ((data_in_posedge and IRQ_POSEDGE) or 
                            (data_in_negedge and IRQ_NEGEDGE));

  hw2sw_o.isr.we        <= '1';
  
  ins_GIC_core : GIC_core
  port map(
    itm_o     => it_o              ,
    its_i     => gic_it            ,
    isr_i     => sw2hw_i.isr.value ,
    isr_o     => hw2sw_o.isr.value ,
    imr_i     => sw2hw_i.imr.enable
    );
end rtl;
