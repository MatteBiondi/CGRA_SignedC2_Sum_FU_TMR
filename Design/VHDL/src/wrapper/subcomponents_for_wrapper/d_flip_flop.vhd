--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describes a D-edge triggered FF with 1 bit.
-- The component has asynchronous reset and an 'enable' port 
-- as input. 
--------------------------------------------------------------
entity d_flip_flop is
  port (
    -- INPUT --
    dff_clk         : in std_logic;   -- Clock
    dff_async_rst_n : in std_logic;   -- Asynchronous reset low
    dff_en          : in std_logic;   -- Enable
    dff_d           : in std_logic;   -- Input data
    -- OUTPUT --
    dff_q           : out std_logic   -- Output data
  );
end entity;


--------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------
architecture dff_arch of d_flip_flop is
begin

  p_DFF: process(dff_clk, dff_async_rst_n) 
  begin
    
    if (dff_async_rst_n = '0') then
      -- Reset case
      dff_q <= '0';
    elsif (rising_edge(dff_clk)) then
      -- Clock rising edge occurs
      if (dff_en = '1') then
        dff_q <= dff_d;
      end if;
    end if;
  
  end process;

end architecture;
