--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describe a tmr version for FIFO with blocks 
-- of N-bits each. The component use a ready-valid handshake 
--------------------------------------------------------------
entity fifo_tmr is
  generic (
  	-- Number of FIFO internal blocks
    FIFO_TMR_DEPTH      : natural := 4;
    -- Dimension of input/output data
    -- 1) bit 0-7 : Data payload
    -- 2) bit 8-9 : Data flag
    FIFO_TMR_DATA_WIDTH : natural := 10;
    -- The description only support N=3 modular redundancy
    -- TMR by default
    FIFO_TMR_N_MODULES  : positive := 3
  );
  port(
    -- INPUT --
    fifo_tmr_clk              : in std_logic;                                           -- Clock
    fifo_tmr_async_rst_n      : in std_logic;                                           -- Asynchronous reset low
    fifo_tmr_data_in          : in std_logic_vector(FIFO_TMR_DATA_WIDTH - 1 downto 0);  -- Input data
    fifo_tmr_valid_in         : in std_logic;                                           -- Validity bit for input data
    fifo_tmr_ready_downstream : in std_logic;                                           -- Ready bit from downstream
    fifo_tmr_sync_final_state : in std_logic;                                           -- Valid bit from final state of another FIFO
                                                                                        -- Set to '1' if not present to ignore its effect

    -- OUTPUT --
    fifo_tmr_data_out         : out std_logic_vector(FIFO_TMR_DATA_WIDTH - 1 downto 0); -- Output data
    fifo_tmr_ready_upstream   : out std_logic;                                          -- Ready bit from upstream
    fifo_tmr_valid_out        : out std_logic                                           -- Validity bit for output data
  );
end entity;

--------------------------------------------------------------
-- Architecture declaration
--------------------------------------------------------------
architecture fifo_tmr_arch of fifo_tmr is
   --------------------------------------------------------------
  -- Types definition
  --------------------------------------------------------------
  -- Signal at position 'i' reppresents the input at the i-th register
  -- Signal at position 'FIFO_TMR_DEPTH' reppresents the output of the last register.
  -- The output of each FIFO stage is composed as follow:
  -- 1) bit 0-7 : Data payload
  -- 2) bit 8-9 : Data flag
  -- 3) bit 10  : Validity bit
  type internal_fifo_signal is array (0 to FIFO_TMR_DEPTH) 
    of std_logic_vector(FIFO_TMR_DATA_WIDTH downto 0);

  --------------------------------------------------------------
  -- Signals declaration
  --------------------------------------------------------------
  signal int_reg_sig    : internal_fifo_signal;                         -- Registers content
  signal int_reg_enable : std_logic_vector(FIFO_TMR_DEPTH-1 downto 0);  -- Enable bits for each stage register

  --------------------------------------------------------------
  -- Components declaration
  --------------------------------------------------------------
  component d_flip_flop_n_tmr is
    generic (
      DFF_TMR_N_BITS    : natural;
      DFF_TMR_N_MODULES : positive
    );
    port (
      dff_tmr_clk         : in std_logic;
      dff_tmr_async_rst_n : in std_logic;
      dff_tmr_en          : in std_logic;
      dff_tmr_d           : in std_logic_vector(DFF_TMR_N_BITS - 1 downto 0);
      dff_tmr_q           : out std_logic_vector(DFF_TMR_N_BITS - 1 downto 0)
    );
  end component;
  attribute dont_touch : string;
  attribute dont_touch of d_flip_flop_n_tmr : component is "true";

begin

  g_DFF: for i in 0 to FIFO_TMR_DEPTH - 1 generate
  
    i_DFF_N: d_flip_flop_n_tmr
      generic map ( 
        -- Dimension of each data contained in FIFO block
        -- 1) bit 0-7 : Data payload
        -- 2) bit 8-9 : Data flag
        -- 3) bit 10  : Validity bit
        DFF_TMR_N_BITS      => FIFO_TMR_DATA_WIDTH + 1,
        -- TMR
        DFF_TMR_N_MODULES   => FIFO_TMR_N_MODULES
      )
      port map (
        dff_tmr_clk     	  => fifo_tmr_clk,
        dff_tmr_async_rst_n => fifo_tmr_async_rst_n,
        dff_tmr_en      	  => int_reg_enable(i),
        dff_tmr_d       	  => int_reg_sig(i),
        dff_tmr_q       	  => int_reg_sig(i+1)
      );
  end generate;

  -- Input at the first register is the concatenation of input valid and input data (flag and payload)
  int_reg_sig(0)      <=  fifo_tmr_valid_in & fifo_tmr_data_in;

  -- Output of the last register is handled to fit the output port of this component
  -- Payload and flag bits assignment 
  fifo_tmr_data_out   <=  int_reg_sig(FIFO_TMR_DEPTH)(FIFO_TMR_DATA_WIDTH-1 downto 0);
  -- Valid bit assignment
  fifo_tmr_valid_out  <=  int_reg_sig(FIFO_TMR_DEPTH)(FIFO_TMR_DATA_WIDTH);

  -- Enable bits handling and Ready upstream output
  p_FIFO_TMR_ENABLE: process (fifo_tmr_sync_final_state, fifo_tmr_ready_downstream, int_reg_sig, int_reg_enable)
    begin
      for i in FIFO_TMR_DEPTH-1 downto 0 loop
       
        if i = FIFO_TMR_DEPTH-1 then
          -- The enable bit of the last FIFO stage requires different management than all the other stages
          int_reg_enable(FIFO_TMR_DEPTH-1) <= (fifo_tmr_sync_final_state and fifo_tmr_ready_downstream) or not int_reg_sig(i+1)(FIFO_TMR_DATA_WIDTH);
        else
          int_reg_enable(i) <= int_reg_enable(i+1) or not int_reg_sig(i+1)(FIFO_TMR_DATA_WIDTH);
        end if;

      end loop;
      
      -- Upstream ready bit handling. A new data can be given to FIFO only in case 
      -- first stage is not in hold state
      fifo_tmr_ready_upstream <=  int_reg_enable(0);
    end process;

end architecture;