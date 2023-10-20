--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- 
--------------------------------------------------------------

entity flag_generator is
  generic (
    -- Number of input sum bit
  	FLG_GEN_IN_N_BITS   : positive  := 8;
    -- Number of flag codification bit
    FLG_GEN_RES_N_BITS  : positive  := 2
  );
  port(
    flg_gen_sum_res     : in  std_logic_vector(FLG_GEN_IN_N_BITS-1 downto 0);
    flg_gen_sum_cout    : in  std_logic;
    flg_gen_flag_res    : out std_logic_vector(FLG_GEN_RES_N_BITS-1 downto 0)
  );
end entity;

architecture flag_gen_arch of flag_generator is
begin
  p_FLG_GEN: process(flg_gen_sum_res, flg_gen_sum_cout) begin
    if (flg_gen_sum_res = (others => '0')) then
      -- "11" : Zero Flag Codification
      flg_gen_flag_res  <=  "11";

    elsif (flg_gen_sum_cout = '1') then
      -- "01" : Overflow Flag Codification
      flg_gen_flag_res  <=  "01";
    
    elsif (flg_gen_sum_res(FLG_GEN_IN_N_BITS-1) = '1')
      -- "10" : Negative Result Flag Codification
      flg_gen_flag_res  <=  "01";

    else
      -- "00" : Other Cases
      flg_gen_flag_res  <=  "00";
    end if;
  end process;
  
end architecture;
