--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all; 

--------------------------------------------------------------
-- Component Description
-- This VHDL file describe a FIFO with blocks of 11 bits each.
-- The component use a ready-valid handshake 
--------------------------------------------------------------

entity fifo is
  generic (
  	-- Number of FIFO internal blocks
    FIFO_DEPTH      : natural := 4;
    -- Dimension of input/output data
    -- 1) bit 0-7 : Data payload
    -- 2) bit 8-9 : Data flag
    FIFO_DATA_WIDTH : natural := 10
  );
  port(
    fifo_clk              : in std_logic;
    fifo_async_rst_n      : in std_logic;

    fifo_data_in          : in std_logic_vector(FIFO_DATA_WIDTH - 1 downto 0);
    fifo_valid_in         : in std_logic;
    fifo_ready_downstream : in std_logic;
    -- Valid bit from final state of another FIFO
    -- Set to '0' if not present to ignore its effect
    fifo_sync_final_state : in std_logic;

    fifo_data_out         : out std_logic_vector(FIFO_DATA_WIDTH - 1 downto 0);
    fifo_ready_upstream   : out std_logic;
    fifo_valid_out        : out std_logic
  );
end entity;

architecture fifo_arch of fifo is
  --------------------------------------------------------------
  -- Types definition
  --------------------------------------------------------------
  -- Signal at position 'i' reppresents the input at the i-th register
  -- Signal at position from 'FIFO_DEPTH' reppresents the output of the last register
  -- 1) bit 0-7 : Data payload
  -- 2) bit 8-9 : Data flag
  -- 3) bit 10  : Validity bit
  type internal_fifo_signal is array (0 to FIFO_DEPTH) 
    of std_logic_vector(FIFO_DATA_WIDTH downto 0);

  --------------------------------------------------------------
  -- Signals declaration
  --------------------------------------------------------------
  signal int_reg_sig    : internal_fifo_signal;
  signal int_reg_valid  : std_logic_vector(FIFO_DEPTH-1 downto 0);
  signal int_reg_enable : std_logic_vector(FIFO_DEPTH-1 downto 0);

  --------------------------------------------------------------
  -- Components declaration
  --------------------------------------------------------------
  component d_flip_flop_n is
    generic ( 
      DFF_N_BITS : natural
    );
    port (
      dff_clk         : in std_logic;
      dff_async_rst_n : in std_logic;
      dff_en          : in std_logic;
      dff_d           : in std_logic_vector(DFF_N_BITS - 1 downto 0);
      
      dff_q           : out std_logic_vector(DFF_N_BITS - 1 downto 0)
    );
  end component;

begin

  g_DFF: for i in 0 to FIFO_DEPTH - 1 generate
  
    i_DFF_N: d_flip_flop_n
      generic map ( 
        -- Dimension of each data contained in FIFO block
        -- 1) bit 0-7 : Data payload
        -- 2) bit 8-9 : Data flag
        -- 3) bit 10  : Validity bit
        DFF_N_BITS      => FIFO_DATA_WIDTH + 1
      )
      port map (
        dff_clk     	  => fifo_clk,
        dff_async_rst_n => fifo_async_rst_n,
        dff_en      	  => int_reg_enable(i),
        dff_d       	  => int_reg_sig(i),
        dff_q       	  => int_reg_sig(i+1)
      );
  end generate;

  -- Input at the first register is the concatenation of input valid and input data (flag and payload)
  int_reg_sig(0)      <=  fifo_valid_in & fifo_data_in;

  -- Output of the last register is handled to fit the output port of this component
  -- Payload and flag bits assignment 
  fifo_data_out       <=  int_reg_sig(FIFO_DEPTH)(FIFO_DATA_WIDTH-1 downto 0);
  -- Valid bit assignment
  fifo_valid_out      <=  int_reg_sig(FIFO_DEPTH)(FIFO_DATA_WIDTH);

  fifo_ready_upstream <=  int_reg_enable(0);
  --TODO: Come diventa in caso di reset?

  p_FIFO_ENABLE: process (fifo_sync_final_state, fifo_ready_downstream, int_reg_valid)
    begin
      for i in FIFO_DEPTH-1 downto 0 loop
        int_reg_valid(i) = int_reg_sig(i+1)(FIFO_DATA_WIDTH);

        if i = FIFO_DEPTH-1 then
          int_reg_enable(FIFO_DEPTH-1) = fifo_sync_final_state or fifo_ready_downstream or not int_reg_valid(i);
        else
          int_reg_enable(i) = int_reg_enable(i+1) or not int_reg_valid(i)
        end if;
      end loop;
    end process;

end architecture;