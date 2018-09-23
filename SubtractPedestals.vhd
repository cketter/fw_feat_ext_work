----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:28:27 09/21/2018 
-- Design Name: 
-- Module Name:    SubtractPedestals - Behavioral 
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

entity SubtractPedestals is
        Port ( 
            clk                               : in   STD_LOGIC;
            WaveAndPedFIFOsReady              : in   STD_LOGIC;
            PacketSize                        : in   STD_LOGIC_VECTOR (9 downto 0);
            interupt                          : in   STD_LOGIC;
            busy                              : out  STD_LOGIC;
            done                              : out  STD_LOGIC;
            PedestalSubtractedWaveforms_Out   : out  STD_LOGIC_VECTOR (11 downto 0)
        );
end SubtractPedestals;

architecture Behavioral of SubtractPedestals is

begin


end Behavioral;

