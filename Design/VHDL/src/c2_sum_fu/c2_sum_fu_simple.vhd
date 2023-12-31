--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describe the adder of a FU with no TMR
--------------------------------------------------------------
entity c2_sum_fu_simple is
  generic (
    -- Dimension of input/output data
    -- 1) bit 0-7 : Data payload
    -- 2) bit 8-9 : Data flag
    SUM_FU_SMP_DATA_WIDTH     : natural   := 10;
    -- Number of flag bits (2 by project specs)
    SUM_FU_SMP_FLAG_WIDTH     : natural   := 2;
    -- Number of payload bits (8 by project specs)
    SUM_FU_SMP_PAYL_WIDTH     : natural   := 8;
    -- Number of register bits (11 by project specs)
    -- Validity bit + Flag + Payload
    SUM_FU_SMP_FULL_WIDTH     : natural   := 11;
    -- Number of bits for configuration word
    SUM_FU_SMP_CFG_WD_N_BITS  : positive  := 2; 
    -- FIFO depth
    SUM_FU_SMP_FIFO_DEPTH     : positive  := 4
  );
  port(
    -- INPUT --
    sum_fu_smp_clk            : in std_logic;                                               -- Clock
    sum_fu_smp_async_rst_n    : in std_logic;                                               -- Asynchronous reset low
    sum_fu_smp_in_a           : in std_logic_vector(SUM_FU_SMP_DATA_WIDTH - 1 downto 0);    -- First operand
    sum_fu_smp_valid_a        : in std_logic;                                               -- Validity bit for first operand
    sum_fu_smp_in_b           : in std_logic_vector(SUM_FU_SMP_DATA_WIDTH - 1 downto 0);    -- Second operand
    sum_fu_smp_valid_b        : in std_logic;                                               -- Validity bit for second operand
    sum_fu_smp_ready_downs    : in std_logic;                                               -- Ready bit by downstream receiver
    sum_fu_smp_conf_wd        : in std_logic_vector(SUM_FU_SMP_CFG_WD_N_BITS - 1 downto 0); -- Configuration word
    -- OUTPUT --
    sum_fu_smp_ready_a        : out std_logic;                                              -- Ready bit to first upstream sender
    sum_fu_smp_ready_b        : out std_logic;                                              -- Ready bit to second upstream sender
    sum_fu_smp_out_data       : out std_logic_vector(SUM_FU_SMP_DATA_WIDTH - 1 downto 0);   -- Output data payload
    sum_fu_smp_out_valid      : out std_logic                                               -- Validity bit for output data
  );
end entity;


--------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------
architecture c2_sum_fu_simple_arch of c2_sum_fu_simple is
  --------------------------------------------------------------
  -- Signals declaration
  --------------------------------------------------------------
  -- Data signals from FIFOs (as output)
  signal int_data_from_fifo1                : std_logic_vector(SUM_FU_SMP_DATA_WIDTH - 1 downto 0);
  signal int_data_from_fifo2                : std_logic_vector(SUM_FU_SMP_DATA_WIDTH - 1 downto 0);
  -- Payload signals from FIFOs (as output) to RCA (as input operand)
  signal int_payload_from_fifo1_to_rca      : std_logic_vector(SUM_FU_SMP_PAYL_WIDTH - 1 downto 0); 
  signal int_payload_from_fifo2_to_rca      : std_logic_vector(SUM_FU_SMP_PAYL_WIDTH - 1 downto 0);
  -- Flag signals from FIFOs (as output) to Flag Selector (as input operand)
  signal int_flag_from_fifo1_to_flag_slc    : std_logic_vector(SUM_FU_SMP_FLAG_WIDTH - 1 downto 0);
  signal int_flag_from_fifo2_to_flag_slc    : std_logic_vector(SUM_FU_SMP_FLAG_WIDTH - 1 downto 0);
  -- Flag signal from Flag Generator (as output) to Flag Selector (as input operand)
  signal int_flag_from_flag_gen_to_flag_slc : std_logic_vector(SUM_FU_SMP_FLAG_WIDTH - 1 downto 0);
  -- Validity bit signals from FIFOs (as output)
  signal int_valid_from_fifo1               : std_logic;
  signal int_valid_from_fifo2               : std_logic;
  -- Validity bit signal to output register (as input)
  signal int_valid_to_out_reg               : std_logic;
  -- Flag signal from Flag Selector (as output) to output register (as input)
  signal int_flag_from_flag_slc_to_out_reg  : std_logic_vector(SUM_FU_SMP_FLAG_WIDTH - 1 downto 0);
  -- Sum overflow result signal from RCA (as output) to Flag Generator (as input)
  signal int_of_from_rca_to_flag_gen        : std_logic;
  -- Sum result signal from RCA (as output) to output register (as input) and Flag Generator (as input)
  signal int_sum_from_rca                   : std_logic_vector(SUM_FU_SMP_PAYL_WIDTH - 1 downto 0);
  -- Data signal (Validity + Flag + Payload) to output register (as input)
  signal int_data_to_out_reg                : std_logic_vector(SUM_FU_SMP_FULL_WIDTH - 1 downto 0);
  -- Data signal (Validity + Flag + Payload) from output register (as output)
  signal int_data_from_out_reg              : std_logic_vector(SUM_FU_SMP_FULL_WIDTH - 1 downto 0);

  --------------------------------------------------------------
  -- Components declaration
  --------------------------------------------------------------
  component fifo is
    generic (
      -- Number of FIFO internal blocks
      FIFO_DEPTH      : natural ;
      -- Dimension of input/output data
      FIFO_DATA_WIDTH : natural
    );
    port(
      -- INPUT --
      fifo_clk              : in std_logic;                                       -- Clock
      fifo_async_rst_n      : in std_logic;                                       -- Asynchronous reset low
      fifo_data_in          : in std_logic_vector(FIFO_DATA_WIDTH - 1 downto 0);  -- Input data
      fifo_valid_in         : in std_logic;                                       -- Validity bit for input data
      fifo_ready_downstream : in std_logic;                                       -- Ready bit from downstream
      fifo_sync_final_state : in std_logic;                                       -- Validity bit from final state of another FIFO
                                                                                  -- Set to '1' if not present to ignore its effect
      -- OUTPUT --
      fifo_data_out         : out std_logic_vector(FIFO_DATA_WIDTH - 1 downto 0); -- Output data
      fifo_ready_upstream   : out std_logic;                                      -- Ready bit from upstream
      fifo_valid_out        : out std_logic                                       -- Validity bit for output data
    );
  end component;


  component ripple_carry_adder is 
    generic (
      -- Number of bits for each operand
      RCA_N_BITS  : positive
    );
    port(
      -- INPUT --
      rca_a       : in std_logic_vector(RCA_N_BITS-1 downto 0);		-- First operand
      rca_b       : in std_logic_vector(RCA_N_BITS-1 downto 0);		-- Second operand
      rca_cin		  :	in std_logic;																	-- Carry input
      -- OUTPUT --
      rca_sum     : out std_logic_vector(RCA_N_BITS-1 downto 0);	-- Sum result
      rca_of  	  : out std_logic																	-- Overflow output
    );
  end component;


  component flag_generator is
    generic (
      -- Number of input sum bit
      FLG_GEN_SUM_N_BITS  : positive  ;
      -- Number of flag codification bit
      FLG_GEN_FLG_N_BITS  : positive
    );
    port(
      -- INPUT --
      flg_gen_sum_res     : in  std_logic_vector(FLG_GEN_SUM_N_BITS-1 downto 0);  -- RCA sum result
      flg_gen_sum_of      : in  std_logic;                                        -- RCA overflow result
      -- OUTPUT --
      flg_gen_flag_res    : out std_logic_vector(FLG_GEN_FLG_N_BITS-1 downto 0)   -- Flag result
    );
  end component;


  component flag_selector is
    generic (
      -- Number of flag encoding bits
      FLG_SLC_FLAG_N_BITS   : positive  ;
      -- Number of bits for configuration word
      FLG_SLC_CFG_WD_N_BITS : positive    
    );
    port(
      -- INPUT --
      flg_slc_from_rca  : in std_logic_vector(FLG_SLC_FLAG_N_BITS-1 downto 0);    -- Flag from rca
      flg_slc_operand_1 : in std_logic_vector(FLG_SLC_FLAG_N_BITS-1 downto 0);    -- Flag operand 1
      flg_slc_operand_2 : in std_logic_vector(FLG_SLC_FLAG_N_BITS-1 downto 0);    -- Flag operand 2
      flg_slc_conf_wd   : in std_logic_vector(FLG_SLC_CFG_WD_N_BITS-1 downto 0);  -- Configuration word
      -- OUTPUT --
      flg_slc_res       : out std_logic_vector(FLG_SLC_FLAG_N_BITS-1 downto 0)    -- Flag result
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

begin
  g_FIFO1 : fifo
    generic map (
      FIFO_DEPTH            =>  SUM_FU_SMP_FIFO_DEPTH,
      FIFO_DATA_WIDTH       =>  SUM_FU_SMP_DATA_WIDTH
    )
    port map (
      fifo_clk              =>  sum_fu_smp_clk,
      fifo_async_rst_n      =>  sum_fu_smp_async_rst_n,
      fifo_data_in          =>  sum_fu_smp_in_a,
      fifo_valid_in         =>  sum_fu_smp_valid_a,
      fifo_ready_downstream =>  sum_fu_smp_ready_downs,
      fifo_sync_final_state =>  int_valid_from_fifo2,
      fifo_data_out         =>  int_data_from_fifo1,
      fifo_ready_upstream   =>  sum_fu_smp_ready_a,
      fifo_valid_out        =>  int_valid_from_fifo1
    );

  g_FIFO2 : fifo
    generic map (
      FIFO_DEPTH            =>  SUM_FU_SMP_FIFO_DEPTH,
      FIFO_DATA_WIDTH       =>  SUM_FU_SMP_DATA_WIDTH
    )
    port map (
      fifo_clk              =>  sum_fu_smp_clk,
      fifo_async_rst_n      =>  sum_fu_smp_async_rst_n,
      fifo_data_in          =>  sum_fu_smp_in_b,
      fifo_valid_in         =>  sum_fu_smp_valid_b,
      fifo_ready_downstream =>  sum_fu_smp_ready_downs,
      fifo_sync_final_state =>  int_valid_from_fifo1,
      fifo_data_out         =>  int_data_from_fifo2,
      fifo_ready_upstream   =>  sum_fu_smp_ready_b,
      fifo_valid_out        =>  int_valid_from_fifo2
    );
  
  g_RCA : ripple_carry_adder
    generic map(
      RCA_N_BITS            =>  SUM_FU_SMP_PAYL_WIDTH
    ) 
    port map(
      rca_a                 =>  int_payload_from_fifo1_to_rca,
      rca_b                 =>  int_payload_from_fifo2_to_rca,
      rca_cin               =>  '0',
      rca_sum               =>  int_sum_from_rca,
      rca_of                =>  int_of_from_rca_to_flag_gen
    );

  g_FLG_GEN : flag_generator
    generic map(
      FLG_GEN_SUM_N_BITS    =>  SUM_FU_SMP_PAYL_WIDTH,
      FLG_GEN_FLG_N_BITS    =>  SUM_FU_SMP_FLAG_WIDTH
    ) 
    port map(
      flg_gen_sum_res       =>  int_sum_from_rca,
      flg_gen_sum_of        =>  int_of_from_rca_to_flag_gen,
      flg_gen_flag_res      =>  int_flag_from_flag_gen_to_flag_slc
    );
  
  g_FLG_SLC : flag_selector
    generic map(
      FLG_SLC_FLAG_N_BITS   =>  SUM_FU_SMP_FLAG_WIDTH,
      FLG_SLC_CFG_WD_N_BITS =>  SUM_FU_SMP_CFG_WD_N_BITS
    )
    port map(
      flg_slc_from_rca      =>  int_flag_from_flag_gen_to_flag_slc,
      flg_slc_operand_1     =>  int_flag_from_fifo1_to_flag_slc,
      flg_slc_operand_2     =>  int_flag_from_fifo2_to_flag_slc,
      flg_slc_conf_wd       =>  sum_fu_smp_conf_wd,
      flg_slc_res           =>  int_flag_from_flag_slc_to_out_reg
    );
  
  g_OUT_REG : d_flip_flop_n
    generic map(
      DFF_N_BITS            =>  SUM_FU_SMP_FULL_WIDTH
    )
    port map(
      dff_clk               =>  sum_fu_smp_clk,
      dff_async_rst_n       =>  sum_fu_smp_async_rst_n,
      dff_en                =>  sum_fu_smp_ready_downs,
      dff_d                 =>  int_data_to_out_reg,
      dff_q                 =>  int_data_from_out_reg
    );

  -- Separate flag and payload from FIFOs output signals
  -- FIFO 1
  int_flag_from_fifo1_to_flag_slc <= int_data_from_fifo1 (SUM_FU_SMP_DATA_WIDTH-1 downto SUM_FU_SMP_PAYL_WIDTH); 
  int_payload_from_fifo1_to_rca   <= int_data_from_fifo1 (SUM_FU_SMP_PAYL_WIDTH-1 downto 0);
  -- FIFO 2
  int_flag_from_fifo2_to_flag_slc <= int_data_from_fifo2 (SUM_FU_SMP_DATA_WIDTH-1 downto SUM_FU_SMP_PAYL_WIDTH);
  int_payload_from_fifo2_to_rca   <= int_data_from_fifo2 (SUM_FU_SMP_PAYL_WIDTH-1 downto 0);
  
  -- Separate validity bit and data from output register data
  sum_fu_smp_out_valid            <= int_data_from_out_reg (SUM_FU_SMP_FULL_WIDTH - 1);
  sum_fu_smp_out_data             <= int_data_from_out_reg (SUM_FU_SMP_FULL_WIDTH - 2 downto 0);

  -- Compute valitidy bit from operands validity bits
  int_valid_to_out_reg            <= int_valid_from_fifo1 and int_valid_from_fifo2;
  
  -- Compose input to output register (as Validity bit + Flag + Payload)
  int_data_to_out_reg             <= int_valid_to_out_reg & int_flag_from_flag_slc_to_out_reg & int_sum_from_rca;
end architecture;