--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity ripple_carry_adder_tb is
  end ripple_carry_adder_tb;

--------------------------------------------------------------
-- Testbench architecture declaration
--------------------------------------------------------------
architecture rca_tb_arch of ripple_carry_adder_tb is
  ------------------------------------------------------------
  -- Testbench constants
  ------------------------------------------------------------
  constant CLK_PERIOD : time    := 100 ns;    -- Clock period
  constant RCA_BIT    : natural := 8;         -- N° of data bits 

  ------------------------------------------------------------
  -- Component to test (DUT) declaration
  ------------------------------------------------------------
  component ripple_carry_adder is 
    generic (
      -- Number of bits for each operand
      RCA_N_BITS  : positive
    );
    port(
      rca_a       : in std_logic_vector(RCA_N_BITS-1 downto 0);   -- First operand
      rca_b       : in std_logic_vector(RCA_N_BITS-1 downto 0);   -- Second operand
      rca_cin		  :	in std_logic;                                 -- Carry input
      rca_sum     : out std_logic_vector(RCA_N_BITS-1 downto 0);  -- Sum result
      rca_of      : out std_logic                                 -- Overflow output
    );
  end component;

  ------------------------------------------------------------
  -- Testbench signals
  ------------------------------------------------------------
  signal clk_tb   : std_logic := '0';                                           -- Clock signal, intialized to '0'
  signal a_tb     : std_logic_vector(RCA_BIT - 1 downto 0) := (others => '0');  -- First operand
  signal b_tb     : std_logic_vector(RCA_BIT - 1 downto 0) := (others => '0');  -- Second operand
  signal cin_tb   : std_logic := '0';                                           -- Carry input
  signal s_tb     : std_logic_vector(RCA_BIT - 1 downto 0);                     -- Sum result
  signal of_tb    : std_logic;                                                  -- Overflow output
  signal testing  : boolean   := true;                                          -- Signal to stop simulation

begin
  -- Define clock behaviour
  clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '0';

  -- Component mapping
  DUT: ripple_carry_adder
    generic map(
      RCA_N_BITS  =>  RCA_BIT
    )
    port map(
      rca_a       =>  a_tb,
      rca_b       =>  b_tb,
      rca_cin     =>  cin_tb,
      rca_sum     =>  s_tb,
      rca_of      =>  of_tb
    );

  -- Test definition
  STIMULUS: process (clk_tb)
    variable t : integer := 0;
  begin
    if rising_edge(clk_tb) then
      
      case t is
        when 0 =>
          report("Start simulation");
          -- Result: s:'00000000' overflow:'0' by default value
        when 1 =>
          a_tb   <= std_logic_vector(to_signed(-3, RCA_BIT));
          b_tb   <= std_logic_vector(to_signed(4, RCA_BIT));
          cin_tb <= '0';
          -- Result: s:'00000001' overflow:'0'
        when 3 =>
          a_tb   <= std_logic_vector(to_signed(-4, RCA_BIT));
          b_tb   <= std_logic_vector(to_signed(3, RCA_BIT));
          cin_tb <= '0';
          -- Result: s:'11111111' overflow:'0'
        when 5 =>
          a_tb   <= std_logic_vector(to_signed(-120, RCA_BIT));
          b_tb   <= std_logic_vector(to_signed(-8, RCA_BIT));
          cin_tb <= '0';
          -- Result: s:'10000000' overflow:'0'
        when 7 =>
          a_tb   <= std_logic_vector(to_signed(120, RCA_BIT));
          b_tb   <= std_logic_vector(to_signed(7, RCA_BIT));
          cin_tb <= '0';
          -- Result: s:'01111111' overflow:'0'
        when 9 =>
          a_tb   <= std_logic_vector(to_signed(127, RCA_BIT));
          b_tb   <= std_logic_vector(to_signed(1, RCA_BIT));
          cin_tb <= '0';
          -- Result: s:'10000000' overflow:'1'
        when 11 =>
          a_tb   <= std_logic_vector(to_signed(127, RCA_BIT));
          b_tb   <= std_logic_vector(to_signed(0, RCA_BIT));
          cin_tb <= '1';
          -- Result: s:'10000000' overflow:'1'
        when 13 =>
          a_tb   <= std_logic_vector(to_signed(-128, RCA_BIT));
          b_tb   <= std_logic_vector(to_signed(-1, RCA_BIT));
          cin_tb <= '0';
          -- Result: s:'01111111' overflow:'1'
        when 15 =>
          report("End simulation");
          testing <= false;

	      when others =>
	        null;
      end case;

      t := t + 1;
    end if;
  end process;

end architecture;