--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity flag_selector_tmr_tb is
  end flag_selector_tmr_tb;

--------------------------------------------------------------
-- Testbench architecture declaration
--------------------------------------------------------------
architecture flg_slc_tmr_tb_arch of flag_selector_tmr_tb is
  ------------------------------------------------------------
  -- Testbench constants
  ------------------------------------------------------------
  constant CLK_PERIOD : time    := 100 ns;    -- Clock period
  constant FLG_BIT    : natural := 2;         -- N° of flag bits
  constant CFG_BIT    : natural := 2;         -- N° of configuration word bits 
  constant N_MODULES  : natural := 3;         -- N° Modules for TMR (3 by definition)

  ------------------------------------------------------------
  -- Component to test (DUT) declaration
  ------------------------------------------------------------
  component flag_selector_tmr is
    generic (
      -- Number of flag codification bit
      FLG_SLC_TMR_FLAG_N_BITS   : positive;
      -- Number of bit for configuration word
      FLG_SLC_TMR_CFG_WD_N_BITS : positive;
      -- The description only support N=3 modular redundancy
      -- TMR by default
      FLG_SLC_TMR_N_MODULES     : positive 
    );
    port(
      -- INPUT --
      flg_slc_tmr_from_rca  : in std_logic_vector(FLG_SLC_TMR_FLAG_N_BITS-1 downto 0);    -- Flag from rca
      flg_slc_tmr_operand_1 : in std_logic_vector(FLG_SLC_TMR_FLAG_N_BITS-1 downto 0);    -- Flag operand 1
      flg_slc_tmr_operand_2 : in std_logic_vector(FLG_SLC_TMR_FLAG_N_BITS-1 downto 0);    -- Flag operand 2
      flg_slc_tmr_conf_wd   : in std_logic_vector(FLG_SLC_TMR_CFG_WD_N_BITS-1 downto 0);  -- Configuration word
      -- OUTPUT --
      flg_slc_tmr_res       : out std_logic_vector(FLG_SLC_TMR_FLAG_N_BITS-1 downto 0)    -- Flag result
    );
  end component;

  ------------------------------------------------------------
  -- Testbench signals
  ------------------------------------------------------------
  signal clk_tb       : std_logic := '0';                                          -- Clock signal, intialized to '0'
  signal from_rca_tb  : std_logic_vector(FLG_BIT - 1 downto 0) := (others => '0'); -- RCA operand
  signal operand_1_tb : std_logic_vector(FLG_BIT - 1 downto 0) := (others => '1'); -- First operand
  signal operand_2_tb : std_logic_vector(FLG_BIT - 1 downto 0) := (others => '1'); -- Second operand
  signal conf_wd_tb   : std_logic_vector(CFG_BIT - 1 downto 0) := (others => '0'); -- Config. word
  signal res_tb       : std_logic_vector(FLG_BIT - 1 downto 0);                    -- Output flag
  signal testing      : boolean := true;                                           -- Signal to stop simulation

begin
  -- Define clock behaviour
  clk_tb <= not clk_tb after CLK_PERIOD/2 when testing else '0';

  -- Component mapping
  DUT: flag_selector_tmr
    generic map(
      FLG_SLC_TMR_FLAG_N_BITS   => FLG_BIT,
      FLG_SLC_TMR_CFG_WD_N_BITS => CFG_BIT,
      FLG_SLC_TMR_N_MODULES     => N_MODULES
    )
    port map(
      flg_slc_tmr_from_rca  =>  from_rca_tb,
      flg_slc_tmr_operand_1 =>  operand_1_tb,
      flg_slc_tmr_operand_2 =>  operand_2_tb,
      flg_slc_tmr_conf_wd   =>  conf_wd_tb,
      flg_slc_tmr_res       =>  res_tb
    );

  -- Test definition
  STIMULUS: process (clk_tb)
    variable t : integer := 0;
  begin
    if rising_edge(clk_tb) then
      
      case t is
        when 0 =>
          report("Start simulation");
          -- Result: res:'00' by default value
        when 1 =>
          from_rca_tb   <=  std_logic_vector(to_unsigned(0, FLG_BIT));
          operand_1_tb  <=  std_logic_vector(to_unsigned(1, FLG_BIT));
          operand_2_tb  <=  std_logic_vector(to_unsigned(0, FLG_BIT));
          conf_wd_tb    <=  std_logic_vector(to_unsigned(1, CFG_BIT));
          -- Result: res:'01'
        when 3 =>
          from_rca_tb   <=  std_logic_vector(to_unsigned(1, FLG_BIT));
          operand_1_tb  <=  std_logic_vector(to_unsigned(1, FLG_BIT));
          operand_2_tb  <=  std_logic_vector(to_unsigned(0, FLG_BIT));
          conf_wd_tb    <=  std_logic_vector(to_unsigned(2, CFG_BIT));
          -- Result: res:'00'
        when 5 =>
          from_rca_tb   <=  std_logic_vector(to_unsigned(1, FLG_BIT));
          operand_1_tb  <=  std_logic_vector(to_unsigned(0, FLG_BIT));
          operand_2_tb  <=  std_logic_vector(to_unsigned(0, FLG_BIT));
          conf_wd_tb    <=  std_logic_vector(to_unsigned(3, CFG_BIT));
          -- Result: res:'01'
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