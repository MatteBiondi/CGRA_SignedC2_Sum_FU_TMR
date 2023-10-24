--------------------------------------------------------------
-- Packages list
--------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all; 
  use IEEE.numeric_std.all;

entity fifo_tb is
end entity;

--------------------------------------------------------------
-- Testbench architecture declaration
--------------------------------------------------------------
architecture fifo_tb_arch of fifo_tb is
  ------------------------------------------------------------
  -- Testbench constants
  ------------------------------------------------------------
  constant CLK_PERIOD : time    := 100 ns;    -- Clock period
  constant T_RESET    : time    := 25 ns;     -- Period before the reset deactivation
  constant DEPTH      : natural := 4;         -- FIFO depth
  constant DATA_WIDTH : natural := 11;        -- FIFO data width

  ------------------------------------------------------------
  -- Component to test (DUT) declaration
  ------------------------------------------------------------
  component fifo is
    generic (
      -- Number of FIFO internal blocks
      FIFO_DEPTH      : natural;
      -- Dimension of input/output data
      -- 1) bit 0-7 : Data payload
      -- 2) bit 8-9 : Data flag
      FIFO_DATA_WIDTH : natural
    );
    port(
      fifo_clk              : in std_logic;                                       -- Clock
      fifo_async_rst_n      : in std_logic;                                       -- Asynchronous reset low
      fifo_data_in          : in std_logic_vector(FIFO_DATA_WIDTH - 1 downto 0);  -- Input data
      fifo_valid_in         : in std_logic;                                       -- Validity bit for input data
      fifo_ready_downstream : in std_logic;                                       -- Ready bit from downstream
      fifo_sync_final_state : in std_logic;                                       -- Validity bit from final state of another FIFO
      fifo_data_out         : out std_logic_vector(FIFO_DATA_WIDTH - 1 downto 0); -- Output data
      fifo_ready_upstream   : out std_logic;                                      -- Ready bit from upstream
      fifo_valid_out        : out std_logic                                       -- Validity bit for output data
    );
  end component;
  
  ------------------------------------------------------------
  -- Testbench signals
  ------------------------------------------------------------
  signal clk_tb           : std_logic := '0';                                             -- Clock signal, intialized to '0'
  signal arstn_tb         : std_logic := '0';                                             -- Asynchronous reset low signal
  signal data_in          : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0'); -- Input data
  signal valid_in         : std_logic := '0';                                             -- Validity bit for input data
  signal ready_downstream : std_logic := '0';                                             -- Ready bit from downstream
  signal sync_final_state : std_logic := '0';                                             -- Validity bit from final state of another FIFO
  signal data_out         : std_logic_vector(DATA_WIDTH - 1 downto 0);                    -- Output data
  signal ready_upstream   : std_logic;                                                    -- Ready bit from upstream
  signal valid_out        : std_logic;                                                    -- Validity bit for output data
  signal testing          : boolean := true;                                              -- Signal to stop simulation

begin
  -- Component mapping
  DUT:fifo
    generic map(
      FIFO_DEPTH            =>  DEPTH,
      FIFO_DATA_WIDTH       =>  DATA_WIDTH
    )
    port map(
      fifo_clk              =>  clk_tb,
      fifo_async_rst_n      =>  arstn_tb,
      fifo_data_in          =>  data_in,
      fifo_valid_in         =>  valid_in,
      fifo_ready_downstream =>  ready_downstream,
      fifo_sync_final_state =>  sync_final_state,
      fifo_data_out         =>  data_out,
      fifo_ready_upstream   =>  ready_upstream,
      fifo_valid_out        =>  valid_out
    );

  -- Define clock behaviour
  clk_tb    <= not clk_tb after CLK_PERIOD/2 when testing else '0';
  -- Define reset behaviour: 'deactivate' reset after T_RESET ns
  arstn_tb  <= '1' after T_RESET; 

  -- Test definition
  STIMULI: process(clk_tb, arstn_tb)
    variable t : integer := 0;
  begin
    if arstn_tb = '0' then
      -- Reset
      data_in           <= (others => '0');
      valid_in          <= '0';
      ready_downstream  <= '0';
      sync_final_state  <= '0';
    elsif rising_edge(clk_tb) then
      case(t) is 
        when 0  =>  
          report("Start simulation");
        when 1  =>  
          data_in           <= (others =>  '1');
          valid_in          <= '1';
          ready_downstream  <= '0';
          sync_final_state  <= '0';
          -- Description: Valid data are presented as input to the FIFO. Downstream receiver is not ready.
          --    The final stage of the other FIFO has no valid data.
          -- Result: All stages have no valid data, so all the enable signals are '1'. 
          --    The new data is saved in the first stage in the next cycle. Ready upstream is '1'.
        when 2  =>  
          data_in           <= (others =>  '1');
          valid_in          <= '0';
          ready_downstream  <= '1';
          sync_final_state  <= '0';
          -- Description: Not valid data are presented as input to the FIFO. Downstream receiver is ready.
          --    The final stage of the other FIFO has no valid data.
          -- Result: Previously presented data passes in the first stage. All the enable signals are '1'.
          --    The first stage will contains not valid data in the next cycle. Ready upstream is '1'.
        when 3  =>  
          data_in           <= (others =>  '0');
          valid_in          <= '1'; 
          ready_downstream  <= '1';
          sync_final_state  <= '0';
          -- Description: Valid data are presented as input to the FIFO. Downstream receiver is ready.
          --    The final stage of the other FIFO has no valid data.
          -- Result: All the previously presented data shift by 1 to the right and first stage now contains
          --    not valid data from previous cycle. The second stage contains valid data. 
          --    All the enable signals are '1'. Ready upstream is '1'.
        when 4  =>  
          data_in           <= (others =>  '0');
          valid_in          <= '0';
          ready_downstream  <= '0';
          sync_final_state  <= '0';
          -- Description: Not valid data are presented as input to the FIFO. Downstream receiver is not ready.
          --    The final stage of the other FIFO has no valid data.
          -- Result: All the previously presented data shift by 1 to the right and first stage now contains
          --    valid data. The second stage is a 'hole' with invalid data. All the enable signals are '1'. 
          --    Ready upstream is '1'.
        when 5  =>  
          data_in           <= (others =>  '1');
          valid_in          <= '1';
          ready_downstream  <= '0';
          sync_final_state  <= '0';
          -- Description: Valid data are presented as input to the FIFO. Downstream receiver is not ready.
          --    The final stage of the other FIFO has no valid data.
          -- Result: All the previously presented data shift by 1 to the right and first stage now contains
          --    invalid data. The third stage is a 'hole' with invalid data. Now the FIFO is full.
          --    All enable signals but the last are '1'. Ready upstream is '1'.
        when 6  =>  
          data_in           <= (others =>  '0');
          valid_in          <= '1';
          ready_downstream  <= '0';
          sync_final_state  <= '0';
          -- Description: Valid data are presented as input to the FIFO. Downstream receiver is not ready.
          --    The final stage of the other FIFO has no valid data.
          -- Result: The FIFO is full. All previously presented data in first and second position shift by 1
          --    to the right and a 'hole' disappears. The previously presented data is written in the first 
          --    stage. The second stage is a 'hole' with invalid data. First and second enable signals are '1'.
          --    Ready upstream is '1'.
        when 7  =>  
          data_in           <= (others =>  '1');
          valid_in          <= '1';
          ready_downstream  <= '0';
          sync_final_state  <= '0';
          -- Description: Valid data are presented as input to the FIFO. Downstream receiver is not ready.
          --    The final stage of the other FIFO has no valid data.
          -- Result: The FIFO is full. The previously presented data in first stage shift by 1 to the right
          --    and a 'hole' disappears. The previously presented data is written in the first stage. Now 
          --    the FIFO is full with no 'hole'. Ready upstream is '0' and all enable signals are '0'.  
        when 8  =>  
          -- Description: Nothing change. FIFO is full and is not ready for accepting data. Valid input data 
          --    have to not be changed till FIFO become ready again.
          -- Result: FIFO waits for downstream to become ready and other FIFO to have valid data in the last 
          --    stage
        when 9  =>  
          ready_downstream  <= '1';
          -- Description: Downstream is now ready. FIFO is full and is not ready for accepting data. 
          --    Valid input data have to not be changed till FIFO become ready again. The final stage of the 
          --    other FIFO has no valid data.
          -- Result:  FIFO waits for other FIFO to have valid data in the last stage. This FIFO is stecked.
        when 10  =>  
          sync_final_state  <= '1';
          -- Description: The other FIFO has valid data in the final stage. This will let the FIFO shift all 
          --    data by 1 to the right in the next cycle.
          -- Result: Now the data at the last stage of this FIFO can be used. All enable signals become '1'.
          --    New data can be presented in the next cycle, in which all data will shift by one.
        when 11  =>  
          data_in           <= (others =>  '0');
          valid_in          <= '1';
          ready_downstream  <= '0';
          -- Description: The input presented since t=7 is now contained in first FIFO stage. A new data is 
          --    presented as input. The old last FIFO stage value is taken from downstream that become not 
          --    ready. 
          -- Result: The FIFO is full. The previously presented data in first stage shift by 1 to the right.
          --    The previously presented data is written in the first stage. Now the FIFO is full with no 'hole'.
          --    Ready upstream is '0' and all enable signals are '0'.
        when 13  =>  
          ready_downstream  <= '1';
          -- Description: A new valid data can not be presented as input. Downstream is now ready.
          -- Result: Now the data at the last stage of this FIFO can be used. All enable signals become '1'.
          --    Ready upstream will become 1 as well. New data can be presented in the next cycle, in which all
          --    data will shift by one. From next cycle FIFO can shift its content to the right.
        when 15 =>
          data_in           <= (others =>  '0');
          valid_in          <= '0';
          -- Description: A new data can be presented as input.
          -- Result: The FIFO is full. The previously presented data in first stage shift by 1 to the right.
          --    The previously presented data is written in the first stage. Ready upstream is '1' and all 
          --    enable signals are '1'. FIFO starts flushing contents till the end of simulation substituting
          --    valid data with not valid data.
        when 20 =>  
          report("End simulation");
          testing <= false;  -- Stops the simulation
        when others => null;
      end case;
      t := t + 1; 
    end if;

  end process;

end architecture;