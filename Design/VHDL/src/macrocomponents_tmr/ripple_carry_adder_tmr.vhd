--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describes a tmr version for a ripple carry 
-- adder for N-bits operands.
-- The component has two inputs of N bits each and a carry 
-- input bit. The results are N bit sum and 1 bit overflow
--------------------------------------------------------------
entity ripple_carry_adder_tmr is
  generic(
    -- The description only support N=3 modular redundancy
    -- TMR by default
    RCA_TMR_N_MODULES : positive := 3;
    -- Number of bits for each operand
    RCA_TMR_N_BITS    : positive := 8
  );
  port (
    -- INPUT --
    rca_tmr_a     : in std_logic_vector(RCA_TMR_N_BITS-1 downto 0);   -- First operand
		rca_tmr_b     : in std_logic_vector(RCA_TMR_N_BITS-1 downto 0);   -- Second operand
		rca_tmr_cin		:	in std_logic;                                     -- Carry input
    -- OUTPUT --
		rca_tmr_sum   : out std_logic_vector(RCA_TMR_N_BITS-1 downto 0);  -- Sum result
		rca_tmr_of    : out std_logic                                     -- Overflow output
  );
end entity;

--------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------
architecture rca_tmr_arch of ripple_carry_adder_tmr is
  ------------------------------------------------------------
  -- Types definition
  ------------------------------------------------------------
  -- Each std_logic_vector has as many elements as the number of bit of final sum + 1 (for overflow)
  -- There are as many array elements as the number of redundant modules
  type BIT_TMR_ARRAY_TYPE is array (0 to RCA_TMR_N_MODULES-1) of std_logic_vector(RCA_TMR_N_BITS downto 0);
  

  --------------------------------------------------------------
  -- Signals declaration
  --------------------------------------------------------------
  -- Signal for outputs from flag selectors
  signal internal_s       : BIT_TMR_ARRAY_TYPE;
  -- Signal for intermediate results to be splitted
  signal rca_majority_res : std_logic_vector(RCA_TMR_N_BITS downto 0);


  ------------------------------------------------------------
  -- Components declaration
  ------------------------------------------------------------
  component ripple_carry_adder is
    generic (
      RCA_N_BITS  : positive
    );
    port(
      rca_a       : in std_logic_vector(RCA_N_BITS-1 downto 0);
      rca_b       : in std_logic_vector(RCA_N_BITS-1 downto 0);
      rca_cin		  :	in std_logic;
      rca_sum     : out std_logic_vector(RCA_N_BITS-1 downto 0);
      rca_of      : out std_logic
    );
  end component;
  attribute dont_touch : string;
  attribute dont_touch of ripple_carry_adder : component is "true";

begin 

  -- Generation of RCA_TMR_N_MODULES RCA
  g_RCA: for i in 0 to RCA_TMR_N_MODULES-1 generate
    i_RCA : ripple_carry_adder
      generic map ( 
        RCA_N_BITS  => RCA_TMR_N_BITS
      )
      port map (
        rca_a     => rca_tmr_a, 
        rca_b     => rca_tmr_b,
        rca_cin		=> rca_tmr_cin,
        rca_sum   => internal_s(i)(RCA_TMR_N_BITS-1 downto 0),
        rca_of    => internal_s(i)(RCA_TMR_N_BITS)
      );
  end generate;

  -- Majority vote election for 3 input bit 
  -- Formula:
  -- Input: x,y,z | Output: r | result: r = NAND(NAND(x,y), NAND(x,z), NAND(y,z)) 
  -- Equivalent to r = xy + yz + xz

  rca_majority_res  <=  (internal_s(0) and internal_s(1)) or 
                        (internal_s(1) and internal_s(2)) or
                        (internal_s(0) and internal_s(2));

  -- Output update
  rca_tmr_of        <=  rca_majority_res(RCA_TMR_N_BITS);
  rca_tmr_sum       <=  rca_majority_res(RCA_TMR_N_BITS-1 downto 0);
end architecture;

