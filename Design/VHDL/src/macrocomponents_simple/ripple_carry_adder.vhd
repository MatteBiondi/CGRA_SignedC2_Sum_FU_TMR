library IEEE;
  use IEEE.std_logic_1164.all; 

entity ripple_carry_adder is 
	generic (
		RCA_N_BITS : positive := 8
	);
	port(
		rca_a     : in std_logic_vector(RCA_N_BITS-1 downto 0);
		rca_b     : in std_logic_vector(RCA_N_BITS-1 downto 0);
		rca_cin		:	in std_logic;
		rca_sum   : out std_logic_vector(RCA_N_BITS-1 downto 0);
		rca_cout  : out std_logic
	);
end entity;

architecture rca_arch of ripple_carry_adder is 

  -- FULL ADDER
  component full_adder is 
		port (
			fa_a    : in std_logic;
			fa_b    : in std_logic;
			fa_cin  : in std_logic;
			fa_s	  : out std_logic;
			fa_cout : out std_logic
		);	
  end component;

  signal carry : std_logic_vector(RCA_N_BITS-1 downto 0);

begin

	g_FA: for i in 0 to RCA_N_BITS-1 generate		
		-- First full adder
		FA_FIRST: if i = 0 generate
			i_FIRST : full_adder 
				port map(
					fa_a		=> rca_a(i),
					fa_b 		=> rca_b(i),
					fa_s 		=> rca_sum(i),
					fa_cin 	=> rca_cin,
					fa_cout => carry(0)
				);    
		end generate;
				
		-- Internal full adders
		FA_INTERNAL: if i > 0 and i < RCA_N_BITS-1 generate
			i_FA : full_adder 
				port map(
					fa_a		=> rca_a(i),
					fa_b 		=> rca_b(i),
					fa_s 		=> rca_sum(i),
					fa_cin 	=> carry(i-1),
					fa_cout => carry(i)
				);    
		end generate;

		-- Last full adder
		FA_LAST: if i = RCA_N_BITS-1 generate
			i_LAST: full_adder 
				port map(
					fa_a 		=> rca_a(i),
					fa_b 		=> rca_b(i),
					fa_s 		=> rca_sum(i),
					fa_cin 	=> carry(i-1),
					fa_cout => rca_cout
				);    
		end generate;
  end generate;

end architecture;
