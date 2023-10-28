--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 
  use IEEE.numeric_std.all;


entity c2_sum_fu_comb_tmr_tb is
end entity;

--------------------------------------------------------------
-- Testbench architecture declaration
--------------------------------------------------------------
architecture sum_fu_comb_tmr_tb of c2_sum_fu_comb_tmr_tb is
  ------------------------------------------------------------
  -- Testbench constants
  ------------------------------------------------------------
  constant CLK_PERIOD   : time      := 100 ns;  -- Clock period
  constant T_RESET      : time      := 25 ns;   -- Period before the reset deactivation
  constant DATA_WIDTH   : natural   := 10;      -- Dimension of input/output data
  constant FLAG_WIDTH   : natural   := 2;       -- Number of flag bits (2 by project specs)
  constant PAYL_WIDTH   : natural   := 8;       -- Number of payload bits (8 by project specs)
  constant FULL_WIDTH   : natural   := 11;      -- Number of register bits (11 by project specs)
  constant CFG_WD_WIDTH : positive  := 2;       -- Number of bits for configuration word 
  constant FIFO_DEPTH   : positive  := 4;       -- FIFO depth
  constant N_MODULES    : positive  := 3;       -- Number of redundant modules

  ------------------------------------------------------------
  -- Component to test (DUT) declaration
  ------------------------------------------------------------
  component c2_sum_fu_comb_tmr is
    generic (
      -- Dimension of input/output data
      SUM_FU_COMB_TMR_DATA_WIDTH     : natural ;
      -- Number of flag bits 
      SUM_FU_COMB_TMR_FLAG_WIDTH     : natural ;
      -- Number of payload bits 
      SUM_FU_COMB_TMR_PAYL_WIDTH     : natural ;
      -- Number of register bits
      -- Validity bit + Flag + Payload
      SUM_FU_COMB_TMR_FULL_WIDTH     : natural ;
      -- Number of bits for configuration word
      SUM_FU_COMB_TMR_CFG_WD_N_BITS  : positive; 
      -- FIFO depth
      SUM_FU_COMB_TMR_FIFO_DEPTH     : positive;
      -- Number of redundant modules
      SUM_FU_COMB_TMR_N_MODULES      : positive

    );
    port(
      -- INPUT --
      sum_fu_comb_tmr_clk          : in std_logic;                                                  -- Clock
      sum_fu_comb_tmr_async_rst_n  : in std_logic;                                                  -- Asynchronous reset low
      sum_fu_comb_tmr_in_a         : in std_logic_vector(SUM_FU_COMB_TMR_DATA_WIDTH - 1 downto 0);  -- First operand
      sum_fu_comb_tmr_valid_a      : in std_logic;                                                  -- Validity bit for first operand
      sum_fu_comb_tmr_in_b         : in std_logic_vector(SUM_FU_COMB_TMR_DATA_WIDTH - 1 downto 0);  -- Second operand
      sum_fu_comb_tmr_valid_b      : in std_logic;                                                  -- Validity bit for second operand
      sum_fu_comb_tmr_ready_downs  : in std_logic;                                                  -- Ready bit by downstream receiver
      sum_fu_comb_tmr_conf_wd      : in std_logic_vector(SUM_FU_COMB_TMR_CFG_WD_N_BITS-1 downto 0); -- Configuration word
      -- OUTPUT --
      sum_fu_comb_tmr_ready_a      : out std_logic;                                                 -- Ready bit to first upstream sender
      sum_fu_comb_tmr_ready_b      : out std_logic;                                                 -- Ready bit to second upstream sender
      sum_fu_comb_tmr_out_data     : out std_logic_vector(SUM_FU_COMB_TMR_DATA_WIDTH - 1 downto 0); -- Output data payload
      sum_fu_comb_tmr_out_valid    : out std_logic                                                  -- Validity bit for output data
    );
  end component;

  ------------------------------------------------------------
  -- Testbench signals
  ------------------------------------------------------------
  signal clk_tb       : std_logic := '0';                                               -- Clock signal, intialized to '0'
  signal arstn_tb     : std_logic := '0';                                               -- Asynchronous reset low
  signal in_a         : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');   -- First operand
  signal valid_a      : std_logic := '0';                                               -- Validity bit for first operand
  signal in_b         : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');   -- Second operand
  signal valid_b      : std_logic := '0';                                               -- Validity bit for second operand
  signal ready_downs  : std_logic := '0';                                               -- Ready bit by downstream receiver
  signal conf_wd      : std_logic_vector(CFG_WD_WIDTH-1 downto 0) := (others => '0');   -- Configuration word
  signal ready_a      : std_logic;                                                      -- Ready bit to first upstream sender
  signal ready_b      : std_logic;                                                      -- Ready bit to second upstream sender
  signal out_data     : std_logic_vector(DATA_WIDTH - 1 downto 0);                      -- Output data payload
  signal out_valid    : std_logic;                                                      -- Validity bit for output data
  signal testing      : boolean   := true;                                              -- Signal to stop simulation


begin
  -- Component mapping
  DUT: c2_sum_fu_comb_tmr
    generic map(
      SUM_FU_COMB_TMR_DATA_WIDTH      => DATA_WIDTH,
      SUM_FU_COMB_TMR_FLAG_WIDTH      => FLAG_WIDTH,
      SUM_FU_COMB_TMR_PAYL_WIDTH      => PAYL_WIDTH,
      SUM_FU_COMB_TMR_FULL_WIDTH      => FULL_WIDTH,
      SUM_FU_COMB_TMR_CFG_WD_N_BITS   => CFG_WD_WIDTH, 
      SUM_FU_COMB_TMR_FIFO_DEPTH      => FIFO_DEPTH,
      SUM_FU_COMB_TMR_N_MODULES       => N_MODULES
    )
    port map(
      sum_fu_comb_tmr_clk             => clk_tb,
      sum_fu_comb_tmr_async_rst_n     => arstn_tb,
      sum_fu_comb_tmr_in_a            => in_a,
      sum_fu_comb_tmr_valid_a         => valid_a,
      sum_fu_comb_tmr_in_b            => in_b,
      sum_fu_comb_tmr_valid_b         => valid_b,
      sum_fu_comb_tmr_ready_downs     => ready_downs,
      sum_fu_comb_tmr_conf_wd         => conf_wd,
      sum_fu_comb_tmr_ready_a         => ready_a,
      sum_fu_comb_tmr_ready_b         => ready_b,
      sum_fu_comb_tmr_out_data        => out_data,
      sum_fu_comb_tmr_out_valid       => out_valid
    );

  -- Define clock behaviour
  clk_tb    <= not clk_tb after CLK_PERIOD/2 when testing else '0';

  -- Test definition
  STIMULI: process(clk_tb, arstn_tb)
    variable t : integer := 0;
  begin
    if arstn_tb = '0' then
      -- Reset
      in_a        <=  (OTHERS => '0');
      valid_a     <=  '0';
      in_b        <=  (OTHERS => '0');
      valid_b     <=  '0';
      ready_downs <=  '0';
      conf_wd     <=  (OTHERS => '0');
      -- Define reset behaviour: 'deactivate' reset after T_RESET ns
      arstn_tb  <= '1' after T_RESET; 
    elsif rising_edge(clk_tb) then
      case(t) is 
        when 0  =>  
          report("Start simulation");
        when 1 =>
          in_a(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          in_a(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(-5,PAYL_WIDTH));
          valid_a     <=  '1';
          -- Description: A new valid data is presented as input to the first FIFO. No valid data
          --    is instead presented as input to second FIFO.
          -- Result: In the next clock cycle this data will occupy the first stage in the first FIFO
        when 2 =>
          in_a(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          in_a(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(3,PAYL_WIDTH));
          valid_a     <=  '1';
          -- Description: A new valid data is presented as input to the first FIFO. No valid data
          --    is instead presented as input to second FIFO.
          -- Result:  In the next clock cycle this data will occupy the first stage in the first FIFO.
          --    Previously presented input now is in the first stage of the first FIFO 
        when 3 =>
          valid_a     <=  '0';
          in_b(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          in_b(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(4,PAYL_WIDTH));
          valid_b     <=  '1';
          -- Description: A new valid data is presented as input to the second FIFO. No valid data
          --    is instead presented as input to first FIFO.
          -- Result:  FIFO_1-> In the next clock cycle an invalid data will be in the first stage ("hole").
          --                    Previously presented data shift by one to the right. Two over four stages are
          --                    full and contain valid data.
          --          FIFO_2-> In the next clock cycle this data will occupy the first stage in the second 
          --                    FIFO. 
        when 4 =>
          in_a(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          in_a(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(1,PAYL_WIDTH));
          valid_a     <=  '1';
          in_b(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          in_b(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(-3,PAYL_WIDTH));
          valid_b     <=  '1';
          -- Description: A new valid data is presented as input to the first and second FIFO.
          -- Result:  FIFO_1-> In the next clock cycle a valid data will be in the first stage 
          --                    ("hole" will be in second stage).  At that point the FIFO will be full.
          --                    Previously presented data now shift by one to the right.
          --          FIFO_2-> In the next clock cycle this data will occupy the first stage in the second 
          --                    FIFO. Previously presented data will shift by one to the right.
          --                    The FIFO will have 2 free stages.
        when 5 =>
          in_b(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          in_b(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(127,PAYL_WIDTH));
          valid_b     <=  '1';
          -- Description: A new valid data is presented as input to the first and second FIFO.
          -- Result:  FIFO_1-> In the next clock cycle a valid data will be in the first stage. 
          --                    Previously presented data (but not in stages 3 and 4) will shift by one to the 
          --                    right. At that point the FIFO will be full without any hole.
          --          FIFO_2-> In the next clock cycle this data will occupy the first stage in the second 
          --                    FIFO. Previously presented data will shift by one to the right.
          --                    The FIFO will have one free stage.
        when 6 =>
          ready_downs <= '1';
          in_a(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(1,FLAG_WIDTH));
          in_a(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(1,PAYL_WIDTH));
          valid_a     <=  '1';
          in_b(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(2,FLAG_WIDTH));
          in_b(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(0,PAYL_WIDTH));
          valid_b     <=  '1';
          -- Description: A new valid data is presented as input to the first and second FIFO.
          --              Ready from downstream is now active but its effect is visible in the next cycle.
          -- Result:  FIFO_1-> A new valid data is presented as input but it can not be save in FIFO because
          --                    it is full so ready to upstream is '0'.
          --          FIFO_2-> In the next clock cycle this data will occupy the first stage in the second 
          --                    FIFO. Previously presented data will shift by one to the right.
          --                    The FIFO will be full.
          --          OUTPUT-> It doesn't change because of the output register that holds its precedent value
          --                    due to the readydownstream that is '0'

          -- From 7 to the end of the simulation (but not in 15) the FIFOs will be injected with the same data 
          -- as in step above.

          -- In 7: A couple of valid data will be outputted from FIFO 1 and 2. The result of the sum will be 
          --        saved in output register and presented as output in the next clock cycle.
          --        Output presents a not valid value
          -- In 8: The first valid result is outputted and a new sum is computed.   (Result: -1   with NF=10 flag)
          -- In 9: The second valid result is outputted and a new sum is computed.  (Result: 0    with ZF=11 flag)
          -- In 10: The third valid result is outputted and a new sum is computed.  (Result: -128 with OF=01 flag )
          -- In 11: The fourth valid result is outputted and a new sum is computed. (Result: 1    with 00 flag)
        when 12 =>
          conf_wd     <=  std_logic_vector(to_unsigned(1,CFG_WD_WIDTH));
          -- Description: A new valid configuration word is presented as input to the component.
          -- Result: In the next clock cycle the result flag should be the same as operator 1 = 01
        when 13 =>
          conf_wd     <=  std_logic_vector(to_unsigned(2,CFG_WD_WIDTH));
          -- Description: A new valid configuration word is presented as input to the component.
          -- Result: In the next clock cycle the result flag should be the same as operator 2 = 10
        when 15 =>
          arstn_tb    <= '0';
          -- Description: Reset is activated
          -- Result: FIFOs will be emptyed and output register will output all zero bits
        when 20 =>  
          report("End simulation");
          testing <= false;  -- Stops the simulation
        when others => null;
      end case;
      t := t + 1; 
    end if;

  end process;
end architecture;
