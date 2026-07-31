library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.NUMERIC_STD.ALL;
library asylum;
use     asylum.sbi_pkg.all;
use     asylum.GPIO_csr_pkg.all;
use     asylum.GPIO_irq_csr_pkg.all;

package gpio_pkg is
-- [COMPONENT_INSERT][BEGIN]
component GPIO_core is
  generic(
    NB_IO            : natural:=8        -- Number of IO. Must be <= SIZE_DATA
    );
  port   (
    clk_i            : in    std_logic;
    cke_i            : in    std_logic;
    arstn_i          : in    std_logic; -- asynchronous reset

    -- To/From IO
    data_i           : in    std_logic_vector (NB_IO-1     downto 0);
    data_o           : out   std_logic_vector (NB_IO-1     downto 0);
    data_oe_o        : out   std_logic_vector (NB_IO-1     downto 0);
    
    sw2hw_i          : in    GPIO_sw2hw_t;
    hw2sw_o          : out   GPIO_hw2sw_t

    );
end component GPIO_core;

component GPIO_irq_core is
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
end component GPIO_irq_core;

component sbi_GPIO is
  generic
    (NAME             : string          := ""
    ;NB_IO            : natural         :=8      -- Number of IO. Must be <= SIZE_DATA
    ;DATA_OE_INIT     : std_logic_vector         -- Direction of the IO after a reset
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

end component sbi_GPIO;

component sbi_GPIO_irq is
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

end component sbi_GPIO_irq;

component GPIO_v1 is
  generic(
    SIZE_ADDR        : natural:=2;       -- Bus Address Width
    SIZE_DATA        : natural:=8;       -- Bus Data    Width
    NB_IO            : natural:=8;       -- Number of IO. Must be <= SIZE_DATA
    DATA_OE_INIT     : std_logic_vector; -- Direction of the IO after a reset
    DATA_OE_FORCE    : std_logic_vector  -- Can change the direction of the IO
    );
  port   (
    clk_i            : in    std_logic;
    cke_i            : in    std_logic;
    arstn_i          : in    std_logic; -- asynchronous reset

    -- To IP
    cs_i             : in    std_logic;
    re_i             : in    std_logic;
    we_i             : in    std_logic;
    addr_i           : in    std_logic_vector (SIZE_ADDR-1 downto 0);
    wdata_i          : in    std_logic_vector (SIZE_DATA-1 downto 0);
    rdata_o          : out   std_logic_vector (SIZE_DATA-1 downto 0);
    busy_o           : out   std_logic;

    -- To/From IO
    data_i           : in    std_logic_vector (NB_IO-1     downto 0);
    data_o           : out   std_logic_vector (NB_IO-1     downto 0);
    data_oe_o        : out   std_logic_vector (NB_IO-1     downto 0)
    );
end component GPIO_v1;

-- [COMPONENT_INSERT][END]

end gpio_pkg;
