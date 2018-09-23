----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:21:57 09/21/2018 
-- Design Name: 
-- Module Name:    WaveformChannelFilter - Behavioral 
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

entity WaveformChannelFilter is
        Port ( 
            clk               : in   STD_LOGIC;
            EventChannelMask  : in   STD_LOGIC_VECTOR (7 downto 0);
            WaveformData_In   : in   STD_LOGIC_VECTOR (11 downto 0);
            WaveformData_Out  : out  STD_LOGIC_VECTOR (11 downto 0);
            busy              : in   STD_LOGIC;
            done              : in   STD_LOGIC
        );
end WaveformChannelFilter;

architecture Behavioral of WaveformChannelFilter is

begin


end Behavioral;

