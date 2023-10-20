--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describe a D-edge triggered FF with N bits.
-- The component has asynchronous reset and an 'enable' port 
-- as input. 
--------------------------------------------------------------

entity d_flip_flop_n is
  generic (
    -- Number of register bits
    -- 1) bit 0-7 : Data payload
    -- 2) bit 8-9 : Data flag
    -- 3) bit 10  : Validity bit
    DFF_N_BITS : natural := 11
  );
  port (
    dff_clk         : in std_logic;
    dff_async_rst_n : in std_logic;
    dff_en          : in std_logic;
    dff_d           : in std_logic_vector(DFF_N_BITS - 1 downto 0);
    
    dff_q           : out std_logic_vector(DFF_N_BITS - 1 downto 0)
  );
end entity;

architecture dff_arch of d_flip_flop_n is
begin

  p_DFF: process(dff_clk, dff_async_rst_n) begin
    if (dff_async_rst_n = '0') then
      dff_q <= (others => '0');
    elsif (rising_edge(dff_clk)) then
      if (dff_en = '1') then
        dff_q <= dff_d;
      end if;
    end if;
  end process;

end architecture;
