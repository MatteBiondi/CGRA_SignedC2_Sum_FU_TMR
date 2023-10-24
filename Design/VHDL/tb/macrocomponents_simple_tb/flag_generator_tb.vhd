--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity flag_generator_tb is
  end flag_generator_tb;

--------------------------------------------------------------
-- Testbench architecture declaration
--------------------------------------------------------------
architecture flg_gen_tb_arch of flag_generator_tb is
  ------------------------------------------------------------
  -- Testbench constants
  ------------------------------------------------------------
  constant CLK_PERIOD : time    := 100 ns;    -- Clock period
  constant FLG_BIT    : natural := 2;         -- N° of flag bits
  constant SUM_BIT    : natural := 8;         -- N° of sum bits 

  ------------------------------------------------------------
  -- Component to test (DUT) declaration
  ------------------------------------------------------------
  component flag_generator is
    generic (
      -- Number of input sum bit
      FLG_GEN_SUM_N_BITS  : positive  := 8;
      -- Number of flag codification bit
      FLG_GEN_FLG_N_BITS  : positive  := 2
    );
    port(
      flg_gen_sum_res     : in  std_logic_vector(FLG_GEN_SUM_N_BITS-1 downto 0);  -- RCA sum result
      flg_gen_sum_of      : in  std_logic;                                        -- RCA overflow result
      flg_gen_flag_res    : out std_logic_vector(FLG_GEN_FLG_N_BITS-1 downto 0)   -- Flag result
    );
  end component;

  ------------------------------------------------------------
  -- Testbench signals
  ------------------------------------------------------------
  signal clk_tb       : std_logic := '0';                                           -- Clock signal, intialized to '0'
  signal sum_res_tb   : std_logic_vector(SUM_BIT - 1 downto 0) := (others => '0');  -- RCA sum result
  signal sum_of_tb    : std_logic := '0';                                           -- RCA sum overflow
  signal flag_res_tb  : std_logic_vector(FLG_BIT - 1 downto 0);                     -- Generated result flag
  signal testing      : boolean   := true;                                          -- Signal to stop simulation

begin
  -- Define clock behaviour
  clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '0';

  -- Component mapping
  DUT: flag_generator
    generic map(
      FLG_GEN_SUM_N_BITS  => SUM_BIT,
      FLG_GEN_FLG_N_BITS  => FLG_BIT
    )
    port map(
      flg_gen_sum_res     =>  sum_res_tb,
      flg_gen_sum_of      =>  sum_of_tb,
      flg_gen_flag_res    =>  flag_res_tb
    );

  -- Test definition
  STIMULUS: process (clk_tb)
    variable t : integer := 0;
  begin
    if rising_edge(clk_tb) then
      
      case t is
        when 0 =>
          report("Start simulation");
          -- Result: flag:'11' (by default value) : Zero Flag
        when 1 =>
          sum_of_tb   <= '1';
          -- Result: flag:'01'  : Overflow
        when 3 =>
          sum_res_tb  <= std_logic_vector(to_signed(-1, SUM_BIT));
          -- Result: flag:'01'  : Overflow
        when 5 =>
          sum_of_tb   <= '0';
          -- Result: flag:'10'  : Negative Result
        when 7 =>
          sum_res_tb  <= std_logic_vector(to_signed(1, SUM_BIT));
          -- Result: flag:'00'  : Other Result
        when 10 =>
          report("End simulation");
          testing <= false;

	      when others =>
	        null;
      end case;

      t := t + 1;
    end if;
  end process;

end architecture;