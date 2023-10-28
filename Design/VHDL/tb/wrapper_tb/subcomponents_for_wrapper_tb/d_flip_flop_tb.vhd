--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity d_flip_flop_tb is
end entity;

--------------------------------------------------------------
-- Testbench architecture declaration
--------------------------------------------------------------
architecture dff_tb_arch of d_flip_flop_tb is
  ------------------------------------------------------------
  -- Testbench constants
  ------------------------------------------------------------
  constant CLK_PERIOD : time    := 100 ns;    -- Clock period
  constant T_RESET    : time    := 25 ns;     -- Period before the reset deactivation

  ------------------------------------------------------------
  -- Component to test (DUT) declaration
  ------------------------------------------------------------
  component d_flip_flop is
    port (
      dff_clk         : in std_logic;   -- Clock
      dff_async_rst_n : in std_logic;   -- Asynchronous reset low
      dff_en          : in std_logic;   -- Enable
      dff_d           : in std_logic;   -- Input data
      dff_q           : out std_logic   -- Output data
    );
  end component;

  ------------------------------------------------------------
  -- Testbench signals
  ------------------------------------------------------------
  signal clk_tb   : std_logic := '0';   -- Clock signal, intialized to '0'
  signal arstn_tb : std_logic := '0';   -- Asynchronous reset low signal
  signal en_tb    : std_logic := '0';   -- Enable signal
  signal d_tb     : std_logic := '0';   -- Input d signal
  signal q_tb     : std_logic;          -- Output q signal
  signal testing  : boolean   := true;  -- Signal to stop simulation

begin
  -- Define clock behaviour
  clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '0';

  -- Component mapping
  DUT: d_flip_flop
    port map(
      dff_clk         =>  clk_tb,
      dff_async_rst_n =>  arstn_tb,
      dff_en          =>  en_tb,
      dff_d           =>  d_tb,
      dff_q           =>  q_tb
    );

  -- Test definition
  STIMULI: process(clk_tb, arstn_tb)
    variable t : integer := 0;
  begin
    if arstn_tb = '0' then
      d_tb  <= '0';
      en_tb <= '0';
      -- Define reset behaviour: 'deactivate' reset
      arstn_tb <= '1' after T_RESET; 
    elsif rising_edge(clk_tb) then
      case(t) is 
        when 0  =>  
          report("Start simulation");
        when 1  =>  d_tb      <= '1';
        when 3  =>  en_tb     <= '1';
        when 5  =>  d_tb      <= '0';
        when 7  =>  en_tb     <= '0';
        when 9  =>  arstn_tb  <= '0'; -- Activate Reset
        when 11 =>  d_tb      <= '1';
        when 20 =>  
          report("End simulation");
          testing <= false;  -- Stops the simulation
        when others => null;
      end case;
      t := t + 1; 
    end if;
  end process;

end architecture;