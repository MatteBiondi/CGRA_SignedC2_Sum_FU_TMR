--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describes a ripple carry adder for N-bits 
-- operands.
-- The component has two inputs of N bits each and a carry 
-- input bit. The results are N bit sum and 1 bit overflow
--------------------------------------------------------------
entity ripple_carry_adder is 
	generic (
		-- Number of bits for each operand
		RCA_N_BITS : positive := 8
	);
	port(
		-- INPUT --
		rca_a     : in std_logic_vector(RCA_N_BITS-1 downto 0);		-- First operand
		rca_b     : in std_logic_vector(RCA_N_BITS-1 downto 0);		-- Second operand
		rca_cin		:	in std_logic;																	-- Carry input
		-- OUTPUT --
		rca_sum   : out std_logic_vector(RCA_N_BITS-1 downto 0);	-- Sum result
		rca_of  	: out std_logic																	-- Overflow output
	);
end entity;

--------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------
architecture rca_arch of ripple_carry_adder is 
  ------------------------------------------------------------
	-- Components declaration
	------------------------------------------------------------
  component full_adder is 
		port (
			fa_a    : in std_logic;
			fa_b    : in std_logic;
			fa_cin  : in std_logic;
			fa_s	  : out std_logic;
			fa_cout : out std_logic
		);	
  end component;

	------------------------------------------------------------
	-- Signals declaration
	------------------------------------------------------------
	-- Carry signal that contains each input carry bit and last carry out
  signal carry : std_logic_vector(RCA_N_BITS downto 0);

begin

	g_FA: for i in 0 to RCA_N_BITS-1 generate				
		-- Full adders generation
		g_FA: full_adder 
			port map(
				fa_a		=> rca_a(i),
				fa_b 		=> rca_b(i),
				fa_cin 	=> carry(i),
				fa_s 		=> rca_sum(i),
				fa_cout => carry(i+1)
			);    
  end generate;

	carry(0) 	<= rca_cin;
	rca_of		<= carry(RCA_N_BITS) xor carry(RCA_N_BITS - 1);
end architecture;
