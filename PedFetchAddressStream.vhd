----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:07:41 09/21/2018 
-- Design Name: 
-- Module Name:    PedFetchAddressStream - Behavioral 
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

entity PedFetchAddressStream is
        Port ( 
            clk                        : in   STD_LOGIC;
            TriggeredChannelList_In    : in   STD_LOGIC_VECTOR (7 downto 0);
            SRAM_AddressStream_Out     : out  STD_LOGIC_VECTOR (21 downto 0)
        );

end PedFetchAddressStream;

architecture Behavioral of PedFetchAddressStream is

begin


end Behavioral;

