--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- 
--------------------------------------------------------------

entity flag_selector is
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
end entity;

architecture flag_slc_arch of flag_selector is
begin
  flg_slc_res <=  flg_slc_operand_1 when flg_slc_conf_wd = "01" else
                  flg_slc_operand_2 when flg_slc_conf_wd = "10" else
                  flg_slc_from_rca;
  
end architecture;
