--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describe a component that take RCA's output
-- (Sum and Overflow flag) and generate flag encoded in this 
-- way:
-- -> "11" : Zero Flag Codification
-- -> "01" : Overflow Flag Codification
-- -> "10" : Negative Result Flag Codification
-- -> "00" : Other Cases
--------------------------------------------------------------
entity flag_generator is
  generic (
    -- Number of input sum bit
  	FLG_GEN_SUM_N_BITS  : positive  := 8;
    -- Number of flag codification bit
    FLG_GEN_FLG_N_BITS  : positive  := 2
  );
  port(
    flg_gen_sum_res     : in  std_logic_vector(FLG_GEN_SUM_N_BITS-1 downto 0);  -- RCA sum result
    flg_gen_sum_of      : in  std_logic;                                        -- RCA overflow result
    flg_gen_flag_res    : out std_logic_vector(FLG_GEN_FLG_N_BITS-1 downto 0)   -- Flag result
  );
end entity;

architecture flag_gen_arch of flag_generator is
begin
  p_FLG_GEN: process(flg_gen_sum_res, flg_gen_sum_of) begin
    if (flg_gen_sum_of = '1') then
      -- "01" : Overflow Flag Codification
      flg_gen_flag_res  <=  "01";

    elsif (or(flg_gen_sum_res) = '0') then
      -- "11" : Zero Flag Codification
      flg_gen_flag_res  <=  "11";
    
    elsif (flg_gen_sum_res(FLG_GEN_SUM_N_BITS-1) = '1') then
      -- "10" : Negative Result Flag Codification
      flg_gen_flag_res  <=  "10";

    else
      -- "00" : Other Cases
      flg_gen_flag_res  <=  "00";
    end if;
  end process;
  
end architecture;
