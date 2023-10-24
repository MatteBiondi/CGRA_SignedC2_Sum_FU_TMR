--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;

--------------------------------------------------------------
-- Component Description
-- This VHDL file describe a full adder that take two inputs of
-- 1 bit each, a cin bit and gives a sum bit and a carry out 
-- bit as output
--------------------------------------------------------------
entity full_adder is 
  port(
    -- INPUT --
    fa_a     : in std_logic;
    fa_b     : in std_logic;
    fa_cin   : in std_logic;
    -- OUTPUT --
    fa_cout  : out std_logic;
    fa_s     : out std_logic
  );
end entity;

--------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------
architecture fa_arch of full_adder is
begin
    -- Sum result
    fa_s    <= fa_a xor fa_b xor fa_cin;
    -- Carry out result
    fa_cout <= (fa_a and fa_b) or (fa_a and fa_cin) or (fa_b and fa_cin);

end architecture;