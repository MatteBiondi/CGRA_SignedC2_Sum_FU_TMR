--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describe a TMR for D-edge triggered FF with
-- N bits. The DFF components have asynchronous reset and 
-- 'enable' port as input. 
--------------------------------------------------------------
entity d_flip_flop_n_tmr is
  generic (
    -- Number of register bits
    -- 1) bit 0-7 : Data payload
    -- 2) bit 8-9 : Data flag
    -- 3) bit 10  : Validity bit
    DFF_TMR_N_BITS      : natural := 11;
    -- The description only support N=3 modular redundancy
    -- TMR by default
    DFF_TMR_N_MODULES   : positive := 3
  );
  port (
    -- INPUT --
    dff_tmr_clk         : in std_logic;                                       -- Clock
    dff_tmr_async_rst_n : in std_logic;                                       -- Asynchronous reset low
    dff_tmr_en          : in std_logic;                                       -- Enable
    dff_tmr_d           : in std_logic_vector(DFF_TMR_N_BITS - 1 downto 0);   -- Input data
    -- OUTPUT --
    dff_tmr_q           : out std_logic_vector(DFF_TMR_N_BITS - 1 downto 0)   -- Output data
  );
end entity;

--------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------
architecture dff_tmr_arch of d_flip_flop_n_tmr is
  --------------------------------------------------------------
  -- Types definition
  --------------------------------------------------------------
  -- Each std_logic_vector has as many elements as the number of bit of each dff
  -- There are as many array elements as the number of redundant modules
  type DFF_TMR_ARRAY_TYPE is array (0 to DFF_TMR_N_MODULES-1) 
    of std_logic_vector(DFF_TMR_N_BITS-1 downto 0);
  
  
  --------------------------------------------------------------
  -- Signals declaration
  --------------------------------------------------------------
  -- Signal for output from DFFs
  signal internal_q   : DFF_TMR_ARRAY_TYPE;


  --------------------------------------------------------------
  -- Components declaration
  --------------------------------------------------------------
  component d_flip_flop_n is
    generic (
      -- Number of register bits
      DFF_N_BITS      : natural
    );
    port (
      dff_clk         : in std_logic;
      dff_async_rst_n : in std_logic;
      dff_en          : in std_logic;
      dff_d           : in std_logic_vector(DFF_N_BITS - 1 downto 0);
      dff_q           : out std_logic_vector(DFF_N_BITS - 1 downto 0)
    );
  end component;

begin
  -- Generation of DFF_TMR_N_MODULES D-Flip-Flop
  g_DFF: for i in 0 to DFF_TMR_N_MODULES-1 generate
    i_DFF : d_flip_flop_n
      generic map ( 
        DFF_N_BITS      => DFF_TMR_N_BITS
      )
      port map (
        dff_clk         => dff_tmr_clk, 
        dff_async_rst_n => dff_tmr_async_rst_n,
        dff_en          => dff_tmr_en,
        dff_d           => dff_tmr_d,
        dff_q           => internal_q(i)
      );
  end generate;

  -- Majority vote election for 3 input data of DFF_TMR_N_BITS each
  -- Formula:
  -- Input: x,y,z | Output: r | result: r = NAND(NAND(x,y), NAND(x,z), NAND(y,z)) 
  -- Equivalent to r = xy + yz + xz
  dff_tmr_q   <=  (internal_q(0) and internal_q(1)) or
                  (internal_q(1) and internal_q(2)) or
                  (internal_q(0) and internal_q(2));

end architecture;
