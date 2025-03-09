-------------------------------------------------------------------------------
-- Title      : pbi_GPIO
-- Project    : PicoSOC
-------------------------------------------------------------------------------
-- File       : pbi_GPIO.vhd
-- Author     : Mathieu Rosiere
-- Company    : 
-- Created    : 2017-03-30
-- Last update: 2025-03-08
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2017
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2025-03-05  0.2      mrosiere use csr from regtool
-- 2017-03-30  0.1      rosiere	Created
-------------------------------------------------------------------------------

library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.numeric_std.ALL;
library work;
library work;
use     work.pbi_pkg.all;
use     work.GPIO_csr_pkg.all;

entity pbi_GPIO is
  generic(
    NB_IO            : natural:=8;     -- Number of IO. Must be <= SIZE_DATA
    DATA_OE_INIT     : std_logic_vector; -- Direction of the IO after a reset
    DATA_OE_FORCE    : std_logic_vector; -- Can change the direction of the IO
    IT_ENABLE        : boolean:=false; -- GPIO can generate interruption
    ID               : std_logic_vector (PBI_ADDR_WIDTH-1 downto 0) := (others => '0')
    );
  port   (
    clk_i            : in    std_logic;
    cke_i            : in    std_logic;
    arstn_i          : in    std_logic; -- asynchronous reset

    -- Bus
    pbi_ini_i        : in    pbi_ini_t;
    pbi_tgt_o        : out   pbi_tgt_t;
    
    -- To/From IO
    data_i           : in    std_logic_vector (NB_IO-1     downto 0);
    data_o           : out   std_logic_vector (NB_IO-1     downto 0);
    data_oe_o        : out   std_logic_vector (NB_IO-1     downto 0);

    -- To/From IT Ctrl
    interrupt_o      : out   std_logic;
    interrupt_ack_i  : in    std_logic
    );

end entity pbi_GPIO;

architecture rtl of pbi_GPIO is
  signal pbi_ini : pbi_ini_t(addr (GPIO_ADDR_WIDTH-1 downto 0),
                              wdata(PBI_DATA_WIDTH -1 downto 0));
  signal pbi_tgt : pbi_tgt_t(rdata(PBI_DATA_WIDTH -1 downto 0));
  
begin  -- architecture rtl

  ins_pbi_wrapper_target : entity work.pbi_wrapper_target_v2(rtl)
  generic map(
    SIZE_DATA      => PBI_DATA_WIDTH ,
    SIZE_ADDR_IP   => GPIO_ADDR_WIDTH,
    ID             => ID
     )
  port map(
    clk_i          => clk_i         ,
    cke_i          => cke_i         ,
    arstn_i        => arstn_i       ,
    pbi_ini_i      => pbi_ini_i     ,
    pbi_tgt_o      => pbi_tgt_o     ,     
    pbi_ini_o      => pbi_ini       ,
    pbi_tgt_i      => pbi_tgt     
    );

  ins_GPIO : entity work.GPIO(rtl)
  generic map(
    NB_IO            => NB_IO         ,
    DATA_OE_INIT     => DATA_OE_INIT  ,
    DATA_OE_FORCE    => DATA_OE_FORCE ,
    IT_ENABLE        => IT_ENABLE    
    )
  port map(
    clk_i            => clk_i          ,
    cke_i            => cke_i          ,
    arstn_i          => arstn_i        ,
    pbi_ini_i        => pbi_ini        ,
    pbi_tgt_o        => pbi_tgt        ,  
    data_i           => data_i         ,
    data_o           => data_o         ,
    data_oe_o        => data_oe_o      ,
    interrupt_o      => interrupt_o    ,
    interrupt_ack_i  => interrupt_ack_i
    );
  
end architecture rtl;
