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

entity TriggerQueue is
        Port ( 
            clk              : in   STD_LOGIC;
            GlobalTriggerIn  : in   STD_LOGIC_VECTOR(11 downto 0);
            ASICsToReadout   : out  STD_LOGIC_VECTOR(3 downto 0);
            EventChannelMask : out  STD_LOGIC_VECTOR(7 downto 0);
        );
end TriggerQueue;

architecture Behavioral of TriggerQueue is

begin


end Behavioral;

