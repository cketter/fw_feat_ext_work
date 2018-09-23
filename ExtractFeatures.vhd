----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:32:55 09/21/2018 
-- Design Name: 
-- Module Name:    ExtracFeatures - Behavioral 
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

entity ExtractFeatures is
        Port ( 
            clk                         : in   STD_LOGIC;
            PedestalSubtractedWaveforms : in   STD_LOGIC_VECTOR (11 downto 0);
            enable                      : in   STD_LOGIC;
            busy                        : out  STD_LOGIC;
            done                        : out  STD_LOGIC;
            interupt                    : in   STD_LOGIC;
            reset                       : in   STD_LOGIC
        );

end ExtractFeatures;

architecture Behavioral of ExtracFeatures is

begin


end Behavioral;

