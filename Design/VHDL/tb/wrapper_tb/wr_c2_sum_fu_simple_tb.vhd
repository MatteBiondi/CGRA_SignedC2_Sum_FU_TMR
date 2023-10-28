--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 
  use IEEE.numeric_std.all;


entity wr_c2_sum_fu_simple_tb is
end entity;

--------------------------------------------------------------
-- Testbench architecture declaration
--------------------------------------------------------------
architecture wr_sum_fu_simple_tb of wr_c2_sum_fu_simple_tb is
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

  ------------------------------------------------------------
  -- Component to test (DUT) declaration
  ------------------------------------------------------------
  component wr_c2_sum_fu_simple is
    generic (
      -- Dimension of input/output data
      DATA_WIDTH    : natural ;
      -- Number of flag bits 
      FLAG_WIDTH    : natural ;
      -- Number of payload bits 
      PAYL_WIDTH    : natural ;
      -- Number of register bits
      -- Validity bit + Flag + Payload
      FULL_WIDTH    : natural ;
      -- Number of bits for configuration word
      CFG_WD_N_BITS : positive; 
      -- FIFO depth
      FIFO_DEPTH    : positive
    );
    port(
      -- INPUT --
      clk           : in std_logic;                                  -- Clock
      async_rst_n   : in std_logic;                                  -- Asynchronous reset low
      in_a          : in std_logic_vector(DATA_WIDTH - 1 downto 0);  -- First operand
      valid_a       : in std_logic;                                  -- Validity bit for first operand
      in_b          : in std_logic_vector(DATA_WIDTH - 1 downto 0);  -- Second operand
      valid_b       : in std_logic;                                  -- Validity bit for second operand
      ready_downs   : in std_logic;                                  -- Ready bit by downstream receiver
      conf_wd       : in std_logic_vector(CFG_WD_N_BITS-1 downto 0); -- Configuration word
      -- OUTPUT --
      ready_a       : out std_logic;                                 -- Ready bit to first upstream sender
      ready_b       : out std_logic;                                 -- Ready bit to second upstream sender
      out_data      : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- Output data payload
      out_valid     : out std_logic                                  -- Validity bit for output data
    );
  end component;

  ------------------------------------------------------------
  -- Testbench signals
  ------------------------------------------------------------
  signal tb_clk          : std_logic := '0';                                               -- Clock signal, intialized to '0'
  signal tb_arstn        : std_logic := '1';                                               -- Asynchronous reset low
  signal tb_in_a         : std_logic_vector(DATA_WIDTH - 1 downto 0)  := (others => '0');  -- First operand
  signal tb_valid_a      : std_logic := '0';                                               -- Validity bit for first operand
  signal tb_in_b         : std_logic_vector(DATA_WIDTH - 1 downto 0)  := (others => '0');  -- Second operand
  signal tb_valid_b      : std_logic := '0';                                               -- Validity bit for second operand
  signal tb_ready_downs  : std_logic := '0';                                               -- Ready bit by downstream receiver
  signal tb_conf_wd      : std_logic_vector(CFG_WD_WIDTH-1 downto 0) := (others => '0');   -- Configuration word
  signal tb_ready_a      : std_logic;                                                      -- Ready bit to first upstream sender
  signal tb_ready_b      : std_logic;                                                      -- Ready bit to second upstream sender
  signal tb_out_data     : std_logic_vector(DATA_WIDTH - 1 downto 0);                      -- Output data payload
  signal tb_out_valid    : std_logic;                                                      -- Validity bit for output data
  signal tb_testing      : boolean   := true;                                              -- Signal to stop simulation


begin
  -- Component mapping
  DUT: wr_c2_sum_fu_simple
    generic map(
      DATA_WIDTH     => DATA_WIDTH,
      FLAG_WIDTH     => FLAG_WIDTH,
      PAYL_WIDTH     => PAYL_WIDTH,
      FULL_WIDTH     => FULL_WIDTH,
      CFG_WD_N_BITS  => CFG_WD_WIDTH, 
      FIFO_DEPTH     => FIFO_DEPTH
    )
    port map(
      clk            => tb_clk,
      async_rst_n    => tb_arstn,
      in_a           => tb_in_a,
      valid_a        => tb_valid_a,
      in_b           => tb_in_b,
      valid_b        => tb_valid_b,
      ready_downs    => tb_ready_downs,
      conf_wd        => tb_conf_wd,
      ready_a        => tb_ready_a,
      ready_b        => tb_ready_b,
      out_data       => tb_out_data,
      out_valid      => tb_out_valid
    );

  -- Define clock behaviour
  tb_clk    <= not tb_clk after CLK_PERIOD/2 when tb_testing else '0';

  -- Test definition
  STIMULI: process(tb_clk, tb_arstn)
    variable t : integer := 0;
  begin
    if tb_arstn = '1' then
      -- Reset
      tb_in_a        <=  (OTHERS => '0');
      tb_valid_a     <=  '0';
      tb_in_b        <=  (OTHERS => '0');
      tb_valid_b     <=  '0';
      tb_ready_downs <=  '0';
      tb_conf_wd     <=  (OTHERS => '0');
      -- Define reset behaviour: 'deactivate' reset after T_RESET ns
      tb_arstn  <= '0' after T_RESET; 
    elsif rising_edge(tb_clk) then
      case(t) is 
        when 0  =>  
          report("Start simulation");
        when 1 =>
          tb_in_a(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          tb_in_a(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(-5,PAYL_WIDTH));
          tb_valid_a  <=  '1';
        when 2 =>
          tb_in_a(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          tb_in_a(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(3,PAYL_WIDTH));
          tb_valid_a  <=  '1';
        when 3 =>
          tb_valid_a  <=  '0';
          tb_in_b(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          tb_in_b(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(4,PAYL_WIDTH));
          tb_valid_b  <=  '1';
        when 4 =>
          tb_in_a(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          tb_in_a(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(1,PAYL_WIDTH));
          tb_valid_a   <=  '1';
          tb_in_b(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          tb_in_b(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(-3,PAYL_WIDTH));
          tb_valid_b   <=  '1';
        when 5 =>
          tb_in_b(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(0,FLAG_WIDTH));
          tb_in_b(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(127,PAYL_WIDTH));
          tb_valid_b   <=  '1';
        when 6 =>
          tb_ready_downs <= '1';
          tb_in_a(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(1,FLAG_WIDTH));
          tb_in_a(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(1,PAYL_WIDTH));
          tb_valid_a     <=  '1';
          tb_in_b(DATA_WIDTH - 1 downto PAYL_WIDTH)  <=  std_logic_vector(to_unsigned(2,FLAG_WIDTH));
          tb_in_b(PAYL_WIDTH - 1 downto 0)           <=  std_logic_vector(to_signed(0,PAYL_WIDTH));
          tb_valid_b     <=  '1';
        when 12 =>
          tb_conf_wd  <=  std_logic_vector(to_unsigned(1,CFG_WD_WIDTH));
        when 13 =>
          tb_conf_wd  <=  std_logic_vector(to_unsigned(2,CFG_WD_WIDTH));
        when 18 =>
          tb_arstn    <= '1';
        when 20 =>  
          report("End simulation");
          tb_testing  <= false;  -- Stops the simulation
        when others => null;
      end case;
      t := t + 1; 
    end if;

  end process;
end architecture;
