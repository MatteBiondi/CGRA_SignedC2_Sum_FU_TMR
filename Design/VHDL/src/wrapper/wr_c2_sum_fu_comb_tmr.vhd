--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describe the wrapper for c2_sum_fu_comb_tmr device
--------------------------------------------------------------
entity wr_c2_sum_fu_comb_tmr is
  generic (
    -- Dimension of input/output data
    -- 1) bit 0-7 : Data payload
    -- 2) bit 8-9 : Data flag
    DATA_WIDTH    : natural   := 10;
    -- Number of flag bits (2 by project specs)
    FLAG_WIDTH    : natural   := 2;
    -- Number of payload bits (8 by project specs)
    PAYL_WIDTH    : natural   := 8;
    -- Number of register bits (11 by project specs)
    -- Validity bit + Flag + Payload
    FULL_WIDTH    : natural   := 11;
    -- Number of bit for configuration word
    CFG_WD_N_BITS : positive  := 2;
    -- FIFO depth
    FIFO_DEPTH    : positive  := 4;
    -- Number of redundant modules (3 by definition)
    N_MODULES     : positive  := 3 
  );
  port(
    -- INPUT --
    clk         : in std_logic;                                   -- Clock
    async_rst_n : in std_logic;                                   -- Asynchronous reset low
    in_a        : in std_logic_vector(DATA_WIDTH - 1 downto 0);   -- First operand
    valid_a     : in std_logic;                                   -- Validity bit for first operand
    in_b        : in std_logic_vector(DATA_WIDTH - 1 downto 0);   -- Second operand
    valid_b     : in std_logic;                                   -- Validity bit for second operand
    ready_downs : in std_logic;                                   -- Ready bit by downstream receiver
    conf_wd     : in std_logic_vector(CFG_WD_N_BITS-1 downto 0);  -- Configuration word
    -- OUTPUT --
    ready_a     : out std_logic;                                  -- Ready bit to first upstream sender
    ready_b     : out std_logic;                                  -- Ready bit to second upstream sender
    out_data    : out std_logic_vector(DATA_WIDTH - 1 downto 0);  -- Output data payload
    out_valid   : out std_logic                                   -- Validity bit for output data
  );
end entity;


--------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------
architecture wr_c2_sum_fu_comb_tmr_arch of wr_c2_sum_fu_comb_tmr is
  --------------------------------------------------------------
  -- Signals declaration
  --------------------------------------------------------------
  -- Reset signal
  signal negated_reset    : std_logic;
  -- First operand data signal
  signal reg_in_a         : std_logic_vector(DATA_WIDTH - 1 downto 0);
  -- First operand validity bit signal
  signal reg_valid_a      : std_logic;
  -- Second operand data signal
  signal reg_in_b         : std_logic_vector(DATA_WIDTH - 1 downto 0);
  -- Second operand validity bit signal
  signal reg_valid_b      : std_logic;
  -- Ready downstream signal
  signal reg_ready_downs  : std_logic;
  -- Configuration word signal
  signal reg_conf_wd      : std_logic_vector(CFG_WD_N_BITS - 1 downto 0);
  -- First operand ready signal
  signal reg_ready_a      : std_logic;
  -- Second operand ready signal
  signal reg_ready_b      : std_logic;
  -- Output data signal
  signal reg_out_data     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  -- Output validity bit signal
  signal reg_out_valid    : std_logic;

  --------------------------------------------------------------
  -- Components declaration
  --------------------------------------------------------------
  component c2_sum_fu_comb_tmr is
    generic (
      -- Dimension of input/output data
      SUM_FU_COMB_TMR_DATA_WIDTH    : natural;
      -- Number of flag bits 
      SUM_FU_COMB_TMR_FLAG_WIDTH    : natural;
      -- Number of payload bits 
      SUM_FU_COMB_TMR_PAYL_WIDTH    : natural;
      -- Number of register bits 
      -- Validity bit + Flag + Payload
      SUM_FU_COMB_TMR_FULL_WIDTH    : natural;
      -- Number of bit for configuration word
      SUM_FU_COMB_TMR_CFG_WD_N_BITS : positive;
      -- FIFO depth
      SUM_FU_COMB_TMR_FIFO_DEPTH    : positive;
      -- Number of redundant modules
      SUM_FU_COMB_TMR_N_MODULES     : positive 
    );
    port(
      -- INPUT --
      sum_fu_comb_tmr_clk           : in std_logic;                                                   -- Clock
      sum_fu_comb_tmr_async_rst_n   : in std_logic;                                                   -- Asynchronous reset low
      sum_fu_comb_tmr_in_a          : in std_logic_vector(SUM_FU_COMB_TMR_DATA_WIDTH - 1 downto 0);   -- First operand
      sum_fu_comb_tmr_valid_a       : in std_logic;                                                   -- Validity bit for first operand
      sum_fu_comb_tmr_in_b          : in std_logic_vector(SUM_FU_COMB_TMR_DATA_WIDTH - 1 downto 0);   -- Second operand
      sum_fu_comb_tmr_valid_b       : in std_logic;                                                   -- Validity bit for second operand
      sum_fu_comb_tmr_ready_downs   : in std_logic;                                                   -- Ready bit by downstream receiver
      sum_fu_comb_tmr_conf_wd       : in std_logic_vector(SUM_FU_COMB_TMR_CFG_WD_N_BITS-1 downto 0);  -- Configuration word
      -- OUTPUT --
      sum_fu_comb_tmr_ready_a       : out std_logic;                                                  -- Ready bit to first upstream sender
      sum_fu_comb_tmr_ready_b       : out std_logic;                                                  -- Ready bit to second upstream sender
      sum_fu_comb_tmr_out_data      : out std_logic_vector(SUM_FU_COMB_TMR_DATA_WIDTH - 1 downto 0);  -- Output data payload
      sum_fu_comb_tmr_out_valid     : out std_logic                                                   -- Validity bit for output data
    );
  end component;

  component d_flip_flop_n is
    generic (
      -- Number of register bits
      DFF_N_BITS      : natural
    );
    port (
      -- INPUT --
      dff_clk         : in std_logic;                                   -- Clock
      dff_async_rst_n : in std_logic;                                   -- Asynchronous reset low
      dff_en          : in std_logic;                                   -- Enable
      dff_d           : in std_logic_vector(DFF_N_BITS - 1 downto 0);   -- Input data
      -- OUTPUT --
      dff_q           : out std_logic_vector(DFF_N_BITS - 1 downto 0)   -- Output data
    );
  end component;

  component d_flip_flop is
    port (
      -- INPUT --
      dff_clk         : in std_logic;   -- Clock
      dff_async_rst_n : in std_logic;   -- Asynchronous reset low
      dff_en          : in std_logic;   -- Enable
      dff_d           : in std_logic;   -- Input data
      -- OUTPUT --
      dff_q           : out std_logic   -- Output data
    );
  end component;

begin
  negated_reset <= not async_rst_n;

  -- Input registers barrier
  g_IN_A_REG: d_flip_flop_n
    generic map(
      DFF_N_BITS        => DATA_WIDTH
    )
    port map(
      dff_clk           => clk,
      dff_async_rst_n   => negated_reset,
      dff_en            => '1',
      dff_d             => in_a,
      dff_q             => reg_in_a
    );

  g_VALID_A_REG: d_flip_flop
    port map(
      dff_clk           => clk,
      dff_async_rst_n   => negated_reset,
      dff_en            => '1',
      dff_d             => valid_a,
      dff_q             => reg_valid_a
    );

  g_IN_B_REG: d_flip_flop_n
    generic map(
      DFF_N_BITS        => DATA_WIDTH
    )
    port map(
      dff_clk           => clk,
      dff_async_rst_n   => negated_reset,
      dff_en            => '1',
      dff_d             => in_b,
      dff_q             => reg_in_b
    );

  g_VALID_B_REG: d_flip_flop
    port map(
      dff_clk           => clk,
      dff_async_rst_n   => negated_reset,
      dff_en            => '1',
      dff_d             => valid_b,
      dff_q             => reg_valid_b
    );

  g_RDY_DOWN_REG: d_flip_flop
    port map(
      dff_clk           => clk,
      dff_async_rst_n   => negated_reset,
      dff_en            => '1',
      dff_d             => ready_downs,
      dff_q             => reg_ready_downs
    );

  g_CONF_WD_REG: d_flip_flop_n
    generic map(
      DFF_N_BITS        => CFG_WD_N_BITS
    )
    port map(
      dff_clk           => clk,
      dff_async_rst_n   => negated_reset,
      dff_en            => '1',
      dff_d             => conf_wd,
      dff_q             => reg_conf_wd
    );

  -- Output registers barrier
  g_RDY_A_REG: d_flip_flop
    port map(
      dff_clk           => clk,
      dff_async_rst_n   => negated_reset,
      dff_en            => '1',
      dff_d             => reg_ready_a,
      dff_q             => ready_a
    );

  g_RDY_B_REG: d_flip_flop
    port map(
      dff_clk           => clk,
      dff_async_rst_n   => negated_reset,
      dff_en            => '1',
      dff_d             => reg_ready_b,
      dff_q             => ready_b
    );

  g_DATA_OUT_REG: d_flip_flop_n
    generic map(
      DFF_N_BITS        => DATA_WIDTH
    )
    port map(
      dff_clk           => clk,
      dff_async_rst_n   => negated_reset,
      dff_en            => '1',
      dff_d             => reg_out_data,
      dff_q             => out_data
    );
  
  g_VLD_OUT_REG: d_flip_flop
    port map(
      dff_clk           => clk,
      dff_async_rst_n   => negated_reset,
      dff_en            => '1',
      dff_d             => reg_out_valid,
      dff_q             => out_valid
    );

  -- Component
  g_C2_SUM_FU_COMB_TMR: c2_sum_fu_comb_tmr
    generic map(
      SUM_FU_COMB_TMR_DATA_WIDTH    => DATA_WIDTH,
      SUM_FU_COMB_TMR_FLAG_WIDTH    => FLAG_WIDTH,
      SUM_FU_COMB_TMR_PAYL_WIDTH    => PAYL_WIDTH,
      SUM_FU_COMB_TMR_FULL_WIDTH    => FULL_WIDTH,
      SUM_FU_COMB_TMR_CFG_WD_N_BITS => CFG_WD_N_BITS, 
      SUM_FU_COMB_TMR_FIFO_DEPTH    => FIFO_DEPTH,
      SUM_FU_COMB_TMR_N_MODULES     => N_MODULES
    )
    port map(
      sum_fu_comb_tmr_clk           => clk,                                               
      sum_fu_comb_tmr_async_rst_n   => negated_reset,                                               
      sum_fu_comb_tmr_in_a          => reg_in_a,    
      sum_fu_comb_tmr_valid_a       => reg_valid_a,                                               
      sum_fu_comb_tmr_in_b          => reg_in_b,    
      sum_fu_comb_tmr_valid_b       => reg_valid_b,                                               
      sum_fu_comb_tmr_ready_downs   => reg_ready_downs,                                               
      sum_fu_comb_tmr_conf_wd       => reg_conf_wd, 
      sum_fu_comb_tmr_ready_a       => reg_ready_a,                                              
      sum_fu_comb_tmr_ready_b       => reg_ready_b,                                              
      sum_fu_comb_tmr_out_data      => reg_out_data,   
      sum_fu_comb_tmr_out_valid     => reg_out_valid
    );

end architecture;