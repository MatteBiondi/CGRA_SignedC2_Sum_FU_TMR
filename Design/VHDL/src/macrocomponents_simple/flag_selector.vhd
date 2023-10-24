--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describes a multiplexer for deciding which 
-- N-bit flag to output as the sum operation. The choice is 
-- based on a configuration word passed in input. 
-- The component has three input flags (two from the operands 
-- and one from the operation result), an input configuration 
-- word, and an output flag.
--------------------------------------------------------------
entity flag_selector is
  generic (
  	-- Number of flag encoding bits
    FLG_SLC_FLAG_N_BITS   : positive  :=  2;
    -- Number of bits for configuration word
    FLG_SLC_CFG_WD_N_BITS : positive  :=  2  
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
end entity;

--------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------
architecture flag_slc_arch of flag_selector is
begin
  -- Select flag based on configuration word
  flg_slc_res <=  flg_slc_operand_1 when flg_slc_conf_wd = "01" else
                  flg_slc_operand_2 when flg_slc_conf_wd = "10" else
                  flg_slc_from_rca;
  
end architecture;
