--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port (
        i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
    );
	end component thunderbird_fsm;

	-- test I/O signals
	signal w_leftin, w_rightin : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_clk : std_logic := '0';
	
	--Outputs
	signal w_left : std_logic_vector(2 downto 0); -- RYG one-hot
	signal w_right : std_logic_vector(2 downto 0) ; -- RYG one-hot
		
	-- constants
	constant k_clk_period : time := 10 ns;
	
	
	
	
begin
	-- PORT MAPS ----------------------------------------
	 uut: thunderbird_fsm port map (
          i_left => w_leftin,
          i_right => w_rightin,
          i_reset => w_reset,
          i_clk => w_clk,
          o_lights_L => w_left,
          o_lights_R => w_right
        );
	
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
    
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	sim_proc: process
	begin
		-- sequential timing		
		w_reset <= '1';
		wait for k_clk_period*1;
		  assert w_left = "000" report "bad reset" severity failure;
		  assert w_right = "000" report "bad reset" severity failure;
		
		w_reset <= '0';
		wait for k_clk_period*1;
		
		-- left turn signal off
		w_leftin <= '0'; wait for k_clk_period;
          assert w_left = "000" report "left turn off" severity failure;
        -- right turn signal off
        w_rightin <= '0'; wait for k_clk_period;
            assert w_right = "000" report "right turn off" severity failure;
        
        --left signal test
        w_leftin <= '1'; wait for k_clk_period;
            assert w_left = "001" report "left blinker on" severity failure;
        wait for k_clk_period; -- time to go to next blink
            assert w_left = "011" report "left blinker phase 2" severity failure;
        wait for k_clk_period; -- time to go to final blink
            assert w_left = "111" report "left blinker phase 3" severity failure;
        
        w_leftin <= '0'; wait for k_clk_period;
        
        -- test right blinker
        
        w_rightin <= '1'; wait for k_clk_period;
            assert w_right = "001" report "right blinker phase 1" severity failure;
        wait for k_clk_period;
            assert w_right = "011" report "right blinker phase 2" severity failure;
        wait for k_clk_period;
            assert w_right = "111" report "right blinker phase 3" severity failure;
            
        --reset and test if both
        wait for k_clk_period;
        w_rightin <= '1'; w_leftin <= '1'; wait for k_clk_period;
            assert w_right = "111" and w_left = "111" report "both flashing working" severity failure;
        wait for k_clk_period; 
            
	
		wait;
	end process;
	
	-----------------------------------------------------	
	
end test_bench;
