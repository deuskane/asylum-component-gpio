-------------------------------------------------------------------------------
-- Title      : sbi_GPIO_irq
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : sbi_GPIO_irq.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2017-03-30
-- Last update: 2026-07-20
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2017
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2026-07-31  1.0      mrosiere Created
-------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.numeric_std.ALL;
library asylum;
use     asylum.sbi_pkg.all;
use     asylum.GPIO_pkg.all;
use     asylum.GPIO_irq_csr_pkg.all;

entity sbi_GPIO_irq is
  generic
    (NAME             : string          := ""
    ;NB_IO            : natural         :=8      -- Number of IO. Must be <= SIZE_DATA
    ;DATA_OE_INIT     : std_logic_vector         -- Direction of the IO after a reset
    ;IRQ_POSEDGE      : std_logic_vector         -- Interrupt on rising edge
    ;IRQ_NEGEDGE      : std_logic_vector         -- Interrupt on falling edge

    );
  port   
    (clk_i            : in    std_logic
    ;cke_i            : in    std_logic
    ;arstn_i          : in    std_logic -- asynchronous reset

    -- Bus
    ;sbi_ini_i        : in    sbi_ini_t
    ;sbi_tgt_o        : out   sbi_tgt_t
    
    -- To/From IO
    ;data_i           : in    std_logic_vector (NB_IO-1     downto 0)
    ;data_o           : out   std_logic_vector (NB_IO-1     downto 0)
    ;data_oe_o        : out   std_logic_vector (NB_IO-1     downto 0)

    -- Interruption
    ;it_o             : out std_logic
    );

end entity sbi_GPIO_irq;

architecture rtl of sbi_GPIO_irq is

  signal sw2hw                  : GPIO_irq_sw2hw_t;
  signal hw2sw                  : GPIO_irq_hw2sw_t;

begin  -- architecture rtl

  ins_csr : GPIO_irq_registers
  generic map
  ( MODULE_NAME  => NAME
   ,DATA_OE_INIT => DATA_OE_INIT 
  )
  port map
  ( clk_i        => clk_i    
   ,arst_b_i     => arstn_i  
   ,sbi_ini_i    => sbi_ini_i
   ,sbi_tgt_o    => sbi_tgt_o
   ,sw2hw_o      => sw2hw    
   ,hw2sw_i      => hw2sw   
  );

  ins_GPIO_irq_core : GPIO_irq_core
  generic map
  ( NB_IO        => NB_IO
   ,IRQ_POSEDGE  => IRQ_POSEDGE
   ,IRQ_NEGEDGE  => IRQ_NEGEDGE

  )
  port map
  ( clk_i        => clk_i    
   ,cke_i        => cke_i    
   ,arstn_i      => arstn_i  
   ,data_i       => data_i   
   ,data_o       => data_o   
   ,data_oe_o    => data_oe_o
   ,sw2hw_i      => sw2hw    
   ,hw2sw_o      => hw2sw
   ,it_o         => it_o
    );
  
end architecture rtl;
