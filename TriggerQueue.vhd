----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:31:36 09/21/2018 
-- Design Name: 
-- Module Name:    TriggerQueue - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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


type asic_and_channel_hit_map is array (0 to 9) of std_logic_vector(14 downto 0); --first define the type of array.
type hit_record is
    record
        asic_ch : asic_and_channel_hit_map; --hit.asic_ch(asicNo)(chNo) returns hit bit
        win_start : std_logic_vector(8 downto 0);
    end record



entity TriggerQueue is
        Port ( 
            clk              : in   STD_LOGIC;
            -- Trigger Inputs
            TriggerIn        : in  hit_record;
            -- Process status flags
            ReadoutBusy      : in  STD_LOGIC;
            PedFifosEmpty    : in  std_logic_vector(MAX_NUM_CHANNELS_TO_READOUT downto 0);
            waveFifosEmpty   : in  std_logic_vector(MAX_NUM_CHANNELS_TO_READOUT downto 0);
            -- Queued trigger outputs
            QueuedTriggerOut : out  hit_record;
            QueuedASICs      : out  STD_LOGIC_VECTOR(3 downto 0)
        );
end TriggerQueue;

architecture Behavioral of TriggerQueue is

begin


end Behavioral;

