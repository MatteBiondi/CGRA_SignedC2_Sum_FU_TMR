--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describe a tmr version for a component that 
-- takes RCA's output (Sum and Overflow flag) and generate flag
-- encoded in this way:
-- -> "11" : Zero Flag Codification
-- -> "01" : Overflow Flag Codification
-- -> "10" : Negative Result Flag Codification
-- -> "00" : Other Cases
--------------------------------------------------------------
entity flag_generator_tmr is
  generic (
    -- Number of input sum bit
  	FLG_GEN_TMR_SUM_N_BITS  : positive  := 8;
    -- Number of flag codification bit
    FLG_GEN_TMR_FLG_N_BITS  : positive  := 2;
    -- The description only support N=3 modular redundancy
    -- TMR by default
    FLG_GEN_TMR_N_MODULES   : positive := 3
  );
  port(
    -- INPUT --
    flg_gen_tmr_sum_res     : in  std_logic_vector(FLG_GEN_TMR_SUM_N_BITS-1 downto 0);  -- RCA sum result
    flg_gen_tmr_sum_of      : in  std_logic;                                            -- RCA overflow result
    -- OUTPUT --
    flg_gen_tmr_flag_res    : out std_logic_vector(FLG_GEN_TMR_FLG_N_BITS-1 downto 0)   -- Flag result
  );
end entity;

--------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------
architecture flag_gen_tmr_arch of flag_generator_tmr is
  --------------------------------------------------------------
  -- Types definition
  --------------------------------------------------------------
  -- Each std_logic_vector has as many elements as the number of bit of each flag_generator
  -- There are as many array elements as the number of redundant modules
  type FLG_GEN_TMR_ARRAY_TYPE is array (0 to FLG_GEN_TMR_N_MODULES-1) 
    of std_logic_vector(FLG_GEN_TMR_FLG_N_BITS-1 downto 0);
  
  
  --------------------------------------------------------------
  -- Signals declaration
  --------------------------------------------------------------
  -- Signal for outputs from flag generators
  signal internal_flag_res  : FLG_GEN_TMR_ARRAY_TYPE;


  --------------------------------------------------------------
  -- Components declaration
  --------------------------------------------------------------
  component flag_generator is
    generic (
      -- Number of input sum bit
      FLG_GEN_SUM_N_BITS  : positive;
      -- Number of flag codification bit
      FLG_GEN_FLG_N_BITS  : positive
    );
    port(
      flg_gen_sum_res     : in  std_logic_vector(FLG_GEN_SUM_N_BITS-1 downto 0);
      flg_gen_sum_of      : in  std_logic;
      flg_gen_flag_res    : out std_logic_vector(FLG_GEN_FLG_N_BITS-1 downto 0)
    );
  end component;

begin
  -- Generation of FLG_GEN_TMR_N_MODULES D-Flip-Flop
  g_GEN: for i in 0 to FLG_GEN_TMR_N_MODULES-1 generate
    i_GEN : flag_generator
      generic map ( 
        FLG_GEN_SUM_N_BITS  =>  FLG_GEN_TMR_SUM_N_BITS,
        FLG_GEN_FLG_N_BITS  =>  FLG_GEN_TMR_FLG_N_BITS
      )
      port map (
        flg_gen_sum_res     => flg_gen_tmr_sum_res, 
        flg_gen_sum_of      => flg_gen_tmr_sum_of,
        flg_gen_flag_res    => internal_flag_res(i)
      );
  end generate;

  -- Majority vote election for 3 input data of FLG_GEN_TMR_FLG_N_BITS each
  -- Formula:
  -- Input: x,y,z | Output: r | result: r = NAND(NAND(x,y), NAND(x,z), NAND(y,z)) 
  -- Equivalent to r = xy + yz + xz
  
  flg_gen_tmr_flag_res  <=  (internal_flag_res(0) and internal_flag_res(1)) or
                            (internal_flag_res(1) and internal_flag_res(2)) or
                            (internal_flag_res(0) and internal_flag_res(2));

  
end architecture;
