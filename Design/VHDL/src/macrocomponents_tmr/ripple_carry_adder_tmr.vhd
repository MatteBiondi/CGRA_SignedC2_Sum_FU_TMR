library IEEE;
  use IEEE.std_logic_1164.all; 

entity ripple_carry_adder_tmr is
  generic(
    -- The description only support N=3 modular redundancy
    -- TMR by default
    RCA_TMR_N_MODULES : positive := 3;
    -- RCA operands bit dimension
    RCA_TMR_N_BITS : positive := 8
  );
  port (
    rca_tmr_a     : in std_logic_vector(RCA_TMR_N_BITS-1 downto 0);
		rca_tmr_b     : in std_logic_vector(RCA_TMR_N_BITS-1 downto 0);
		rca_tmr_cin		:	in std_logic;
		rca_tmr_sum   : out std_logic_vector(RCA_TMR_N_BITS-1 downto 0);
		rca_tmr_cout  : out std_logic
  );
end entity;

architecture rca_tmr_arch of ripple_carry_adder_tmr is
  
  component ripple_carry_adder is
    generic (
      RCA_N_BITS  : positive
    );
    port(
      rca_a       : in std_logic_vector(RCA_N_BITS-1 downto 0);
      rca_b       : in std_logic_vector(RCA_N_BITS-1 downto 0);
      rca_cin		  :	in std_logic;
      rca_sum     : out std_logic_vector(RCA_N_BITS-1 downto 0);
      rca_cout    : out std_logic
    );
  end component;

  -- Each std_logic_vector has as many elements as the number of bit of final sum + 1 (for carry_out)
  -- There are as many array elements as the number of redundant modules
  type BIT_TMR_ARRAY_TYPE is array (0 to RCA_TMR_N_MODULES-1) of std_logic_vector(RCA_TMR_N_BITS downto 0);
  
  
  signal internal_s       : BIT_TMR_ARRAY_TYPE;
  signal rca_majority_res : std_logic_vector(RCA_TMR_N_BITS downto 0);

begin 

  -- Generation of RCA_TMR_N_MODULES RCA
  g_RCA: for i in 0 to RCA_TMR_N_MODULES-1 generate
    i_RCA : ripple_carry_adder
      generic map ( 
        RCA_N_BITS  => RCA_TMR_N_BITS-1
      )
      port map (
        rca_a     => rca_tmr_a, 
        rca_b     => rca_tmr_b,
        rca_cin		=> rca_tmr_cin,
        rca_sum   => internal_s(i)(RCA_TMR_N_BITS-2 downto 0),
        rca_cout  => internal_s(i)(RCA_TMR_N_BITS-1)
      );
  end generate;

  -- Majority vote election for 3 input bit 
  -- Formula:
  -- Input: x,y,z | Output: r | result: r = NAND(NAND(x,y), NAND(x,z), NAND(y,z)) 

  rca_majority_res  <=  NAND(
                          NAND(internal_s(0),internal_s(1)),
                          NAND(internal_s(1),internal_s(2)),
                          NAND(internal_s(0),internal_s(2))
                        );

  rca_tmr_cout      <=  rca_majority_res(RCA_TMR_N_BITS-1);
  rca_tmr_sum       <=  rca_majority_res(RCA_TMR_N_BITS-2 downto 0);
end architecture;

