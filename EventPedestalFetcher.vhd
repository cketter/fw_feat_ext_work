----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:07:41 09/21/2018 
-- Design Name: 
-- Module Name:    EventPedestalFetcher - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--     The scope of this module is a single channel. This module will be called in 
-- series for as many hits as are present. For each call, the output data will
-- be wired to the appropriate pedestal fifo in the parallel processing section.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


constant MAX_NUM_CHANNELS_TO_READOUT : integer :=20;
type hit_map is array (0 to MAX_NUM_CHANNELS_TO_READOUT - 1) of std_logic_vector(7 downto 0); --first define the type of array.
type hit_record is
    record
        asic_and_ch : hit_map; --hit.asic_ch(hitNo) returns slv("4bit asic" & "4bit ch")
        win_start   : std_logic_vector(8 downto 0); --hit.win_start returns slv("9bit window")
        hit_count   : integer;
     end record



entity EventPedestalFetcher is
        Port ( 
            clk              : in   STD_LOGIC;
            enable           : in   STD_LOGIC;
            busy             : out  STD_LOGIC;
            hit_index        : in   integer;
            TriggerIn        : in   hit_record;
            PedestalDataOut  : out  STD_LOGIC_VECTOR (23 downto 0)
        );

end EventPedestalFetcher;

architecture Behavioral of EventPedestalFetcher is


  COMPONENT PedRAMaccess
	    PORT(
		      clk : IN std_logic;
		      addr : IN std_logic_vector(21 downto 0);
		      wval0 : IN std_logic_vector(11 downto 0);
		      wval1 : IN std_logic_vector(11 downto 0);
		      rw : IN std_logic;
		      update : IN std_logic;
		      ram_datar : IN std_logic_vector(7 downto 0);
		      ram_busy : IN std_logic;          
		      rval0 : OUT std_logic_vector(11 downto 0);
		      rval1 : OUT std_logic_vector(11 downto 0);
		      busy : OUT std_logic;
		      ram_addr : OUT std_logic_vector(21 downto 0);
		      ram_dataw : OUT std_logic_vector(7 downto 0);
		      ram_rw : OUT std_logic;
		      ram_update : OUT std_logic
		  );
	END COMPONENT;

  type pedestal_fetching_machine is (
      ped_fetch_machine_is_idle,
      ped_fetch_machine_is_addressing,
      ped_fetch_machine_is_addrwait1
      ped_fetch_machine_is_addrwait2
      ped_fetch_machine_is_addrwait3
      ped_fetch_machine_is_reading
      ped_fetch_machine_is_addrwait1
      ped_fetch_machine_is_addrwait2
      ped_fetch_machine_is_addrwait3
  );
  signal next_state	: pedestal_fetching_machine := ped_fetch_machine_is_idle;

  signal trig_in : hit_record;
  signal SampleNumber : integer := 0;
  signal SRAM_addr : std_logic_vector(21 downto 0);
  signal SRAM_update : STD_LOGIC := "0";
  signal SRAM_rval0 : std_logic_vector(11 downto 0);
  signal SRAM_rval1 : std_logic_vector(11 downto 0);

begin

    U1 : PedRAMaccess
        port map ( 
		        clk => clk,
		        addr => SRAM_addr,
		        wval0 => "000000000000",
		        wval1 => "000000000000",
		        rw => '0',-- read only
		        update => SRAM_update,
		        ram_datar => ram_data,
		        ram_busy => ram_busy

		        rval0 => SRAM_rval0,
		        rval1 => SRAM_rval1,
		        busy => ped_sa_busy,
		        ram_addr => ram_addr,
		        ram_dataw => open,--"00000000",
		        ram_rw => open,--'0',
		        ram_update => ram_update
            
        );


	process(clk) begin
		if (rising_edge(clk)) then
			case next_state is

        when ped_fetch_machine_is_idle =>
          if enable = "1" then
            next_state <= ped_fetch_machine_is_preprocessing;
            trig_in <= TriggerIn;
            SampleNumber <= 0;
				  else
            busy <= "0";
            next_state <= ped_fetch_machine_is_idle;
          end if;

				-- read cycle time for SRAM is 55ns min. This is min 7 clock cycles at 7.861ns clock period.
        -- address and wait . . . 
        when ped_fetch_machine_is_addressing =>
          if SampleNumber < 128 then
            busy <= "1";
            SRAM_update <= "1";
            SRAM_addr <= trig_in.asic_ch(hit_index) & std_logic_vector(unsigned(trig_in.win_start & SampleNumber) + SampleNumber); -- ASIC, CH, WinAdd, Sample
            SampleNumber <= SampleNumber+2;
            next_state <= ped_fetch_machine_is_reading;
          else 
            next_state <= ped_fetch_machine_is_idle;
            busy <= "0";
          end if;
        when ped_fetch_machine_is_addrwait1 =>
            next_state <= ped_fetch_machine_is_addrwait2;
        when ped_fetch_machine_is_addrwait2 =>
            next_state <= ped_fetch_machine_is_addrwait3;
        when ped_fetch_machine_is_addrwait3 =>
            next_state <= ped_fetch_machine_is_reading;

        -- read and wait . . .
        when ped_fetch_machine_is_reading =>
            SRAM_update <= "0";
            PedestalDataOut <= SRAM_rval0 & SRAM_rval1;
            next_state <= ped_fetch_machine_is_readwait1;
        when ped_fetch_machine_is_readwait1 =>
            next_state <= ped_fetch_machine_is_readwait2;
        when ped_fetch_machine_is_readwait2 =>
            next_state <= ped_fetch_machine_is_readwait3;
        when ped_fetch_machine_is_readwait3 =>
            next_state <= ped_fetch_machine_is_addressing;

      end case;
		end if;
	end process;


end Behavioral;

