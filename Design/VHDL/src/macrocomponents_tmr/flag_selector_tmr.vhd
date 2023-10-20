--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- 
--------------------------------------------------------------

entity flag_selector_tmr is
  generic (
  	-- Number of flag codification bit
    FLG_SLC_TMR_FLAG_N_BITS   : positive  :=  2;
    -- Number of bit for configuration word
    FLG_SLC_TMR_CFG_WD_N_BITS : positive  :=  2;
    -- The description only support N=3 modular redundancy
    -- TMR by default
    FLG_SLC_TMR_N_MODULES     : positive := 3 
  );
  port(
    flg_slc_tmr_from_rca  : in std_logic_vector(FLG_SLC_TMR_FLAG_N_BITS-1 downto 0);
    flg_slc_tmr_operand_1 : in std_logic_vector(FLG_SLC_TMR_FLAG_N_BITS-1 downto 0);
    flg_slc_tmr_operand_2 : in std_logic_vector(FLG_SLC_TMR_FLAG_N_BITS-1 downto 0);
    flg_slc_tmr_conf_wd   : in std_logic_vector(FLG_SLC_TMR_CFG_WD_N_BITS-1 downto 0);
    flg_slc_tmr_res       : out std_logic_vector(FLG_SLC_TMR_FLAG_N_BITS-1 downto 0)
  );
end entity;

architecture flag_slc_tmr_arch of flag_selector_tmr is
  --------------------------------------------------------------
  -- Types definition
  --------------------------------------------------------------
  -- Each std_logic_vector has as many elements as the number of bit of each flag_selector
  -- There are as many array elements as the number of redundant modules
  type FLG_SLC_TMR_ARRAY_TYPE is array (0 to FLG_SLC_TMR_N_MODULES-1) 
    of std_logic_vector(FLG_SLC_TMR_RES_N_BITS-1 downto 0);
  
  
  --------------------------------------------------------------
  -- Signals declaration
  --------------------------------------------------------------
  signal internal_flag_res  : FLG_SLC_TMR_ARRAY_TYPE;


  --------------------------------------------------------------
  -- Components declaration
  --------------------------------------------------------------
  component flag_selector is
    generic (
      -- Number of flag codification bit
      FLG_SLC_FLAG_N_BITS   : positive  :=  2;
      -- Number of bit for configuration word
      FLG_SLC_CFG_WD_N_BITS : positive  :=  2  
    );
    port(
      flg_slc_from_rca  : in std_logic_vector(FLG_SLC_FLAG_N_BITS-1 downto 0);
      flg_slc_operand_1 : in std_logic_vector(FLG_SLC_FLAG_N_BITS-1 downto 0);
      flg_slc_operand_2 : in std_logic_vector(FLG_SLC_FLAG_N_BITS-1 downto 0);
      flg_slc_conf_wd   : in std_logic_vector(FLG_SLC_CFG_WD_N_BITS-1 downto 0);
      flg_slc_res       : out std_logic_vector(FLG_SLC_FLAG_N_BITS-1 downto 0)
    );
  end component;

begin
  -- Generation of FLG_SLC_TMR_N_MODULES D-Flip-Flop
  g_SLC: for i in 0 to FLG_SLC_TMR_N_MODULES-1 generate
    i_SLC : flag_selector
      generic map ( 
        FLG_SLC_FLAG_N_BITS     =>  FLG_SLC_TMR_FLAG_N_BITS,
        FLG_SLC_CFG_WD_N_BITS   =>  FLG_SLC_TMR_CFG_WD_N_BITS
      )
      port map (
        flg_slc_from_rca    =>  flg_slc_tmr_from_rca,
        flg_slc_operand_1   =>  flg_slc_tmr_operand_1,
        flg_slc_operand_2   =>  flg_slc_tmr_operand_2,
        flg_slc_conf_wd     =>  flg_slc_tmr_conf_wd,
        flg_slc_res         =>  internal_flag_res(i)
      );
  end generate;

  -- Majority vote election for 3 input data of FLG_SLC_TMR_N_BITS each
  -- Formula:
  -- Input: x,y,z | Output: r | result: r = NAND(NAND(x,y), NAND(x,z), NAND(y,z)) 

  flg_slc_tmr_res   <=  NAND(
                          NAND(internal_flag_res(0),internal_flag_res(1)),
                          NAND(internal_flag_res(1),internal_flag_res(2)),
                          NAND(internal_flag_res(0),internal_flag_res(2))
                        );
  
  
end architecture;
