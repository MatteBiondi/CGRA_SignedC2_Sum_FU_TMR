library IEEE;
  use IEEE.std_logic_1164.all;

entity full_adder is 
  port(
    fa_a     : in std_logic;
    fa_b     : in std_logic;
    fa_cin   : in std_logic;
    fa_cout  : out std_logic;
    fa_s     : out std_logic
  );
end entity;

architecture fa_arch for full_adder is
begin
    fa_s    <= fa_a xor fa_b xor fa_cin;
    fa_cout <= (fa_a and fa_b) or (fa_a and fa_cin) or (fa_b and fa_cin);

end architecture;