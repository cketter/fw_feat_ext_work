----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:16:23 09/21/2018 
-- Design Name: 
-- Module Name:    TriggerTX_Readout - Behavioral 
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

entity TriggerTX_Readout is
        Port ( 
            clk                 : in   STD_LOGIC;
            ASICsToReadout      : in   STD_LOGIC_VECTOR (3 downto 0);
            TriggerTX_Out       : out  STD_LOGIC_VECTOR (3 downto 0);
            busy                : out  STD_LOGIC;
            done                : out  STD_LOGIC
        );
end TriggerTX_Readout;

architecture Behavioral of TriggerTX_Readout is

begin


end Behavioral;

