--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;

entity full_adder_tb is
end full_adder_tb;

--------------------------------------------------------------
-- Testbench architecture declaration
--------------------------------------------------------------
architecture fa_tb_arch of full_adder_tb is
  ------------------------------------------------------------
  -- Testbench constants
  ------------------------------------------------------------
  constant CLK_PERIOD : time := 100 ns;     -- Clock period

  ------------------------------------------------------------
  -- Component to test (DUT) declaration
  ------------------------------------------------------------
  component full_adder
    port (
      fa_a    : in  std_logic;
      fa_b    : in  std_logic;
      fa_cin  : in  std_logic;
      fa_cout : out std_logic;
      fa_s    : out std_logic
    );
  end component;

  ------------------------------------------------------------
  -- Testbench signals
  ------------------------------------------------------------
  signal clk_tb   : std_logic := '0'; -- Clock signal, intialized to '0'
  signal a_tb     : std_logic := '0'; -- First operand
  signal b_tb     : std_logic := '0'; -- Second operand
  signal cin_tb   : std_logic := '0'; -- Carry input
  signal s_tb     : std_logic;        -- Sum result
  signal cout_tb  : std_logic;        -- Carry output
  signal testing  : boolean := true;  -- Signal to stop simulation

begin
  -- Define clock behaviour
  clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '0';

  -- Component mapping
  DUT: full_adder
    port map(
      fa_a    => a_tb,
      fa_b    => b_tb,
      fa_cin  => cin_tb,
      fa_cout => cout_tb,
      fa_s    => s_tb
    );

  -- Test definition
  STIMULUS: process (clk_tb)
    variable t : integer := 0;
  begin
    if rising_edge(clk_tb) then
      case t is
        when 0 =>
          report("Start simulation");
          a_tb   <= '0';
          b_tb   <= '0';
          cin_tb <= '0';
          -- Result: s:'0' cout:'0'
        when 1 =>
          a_tb   <= '1';
          b_tb   <= '0';
          cin_tb <= '0';
          -- Result: s:'1' cout:'0'
        when 2 =>
          a_tb   <= '0';
          b_tb   <= '1';
          cin_tb <= '1';
          -- Result: s:'0' cout:'1'
        when 3 =>
          a_tb   <= '1';
          b_tb   <= '1';
          cin_tb <= '1';
          -- Result: s:'1' cout:'1'
        when 5 =>
          a_tb   <= '1';
          b_tb   <= '1';
          cin_tb <= '0';
          -- Result: s:'0' cout:'1'
        when 10 =>
          a_tb   <= '0';
          b_tb   <= '1';
          cin_tb <= '0';
          -- Result: s:'1' cout:'0'
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
