----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:11:26 09/21/2018 
-- Design Name: 
-- Module Name:    FetchPedestals - Behavioral 
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

entity ParallelProcessing is
        Port ( 
            clk                     : in  STD_LOGIC;
            PedFIFO_wr_en           : in STD_LOGIC;
            PedestalData_In         : in  STD_LOGIC_VECTOR (23 downto 0);
            PedFIFO_empty           : out STD_LOGIC;
            WaveFIFO_wr_en          : in STD_LOGIC;
            WaveformData_In         : in  STD_LOGIC_VECTOR (11 downto 0);    
            WaveFIFO_empty          : out STD_LOGIC;  
            busy                    : out  STD_LOGIC;
            done                    : out  STD_LOGIC
        );
end ParallelProcessing;

architecture Behavioral of FetchPedestals is

    COMPONENT SubtractPedestals
        Port ( 
            clk                               : in   STD_LOGIC;
            WaveAndPedFIFOsReady              : in   STD_LOGIC;
            PacketSize                        : in   STD_LOGIC_VECTOR (9 downto 0);
            interupt                          : in   STD_LOGIC;
            busy                              : out  STD_LOGIC;
            done                              : out  STD_LOGIC;
            PedestalSubtractedWaveforms_Out   : out  STD_LOGIC_VECTOR (11 downto 0)
        );
    END COMPONENT;


    COMPONENT ExtractFeatures
        Port ( 
            clk                         : in   STD_LOGIC;
            PedestalSubtractedWaveforms : in   STD_LOGIC_VECTOR (11 downto 0);
            enable                      : in   STD_LOGIC;
            busy                        : out  STD_LOGIC;
            done                        : out  STD_LOGIC;
            interupt                    : in   STD_LOGIC;
            reset                       : in   STD_LOGIC
        );
    END COMPONENT;


    COMPONENT PedFIFO
        PORT (
            CLK                       : IN  std_logic;
            RST                       : IN  std_logic;
            WR_EN 		                : IN  std_logic;
            RD_EN                     : IN  std_logic;
            DIN                       : IN  std_logic_vector(23 DOWNTO 0);
            DOUT                      : OUT std_logic_vector(23 DOWNTO 0);
            FULL                      : OUT std_logic;
            EMPTY                     : OUT std_logic
        );
    end COMPONENT;

    COMPONENT waveFIFO
        PORT (
            CLK                       : IN  std_logic;
            RST                       : IN  std_logic;
            WR_EN 		                : IN  std_logic;
            RD_EN                     : IN  std_logic;
            DIN                       : IN  std_logic_vector(11 DOWNTO 0);
            DOUT                      : OUT std_logic_vector(11 DOWNTO 0);
            FULL                      : OUT std_logic;
            EMPTY                     : OUT std_logic
        );
    end COMPONENT;

    signal internal_PedestalData_In : std_logic_vector(11 downto 0);
    signal PedFIFO_din : std_logic_vector(11 downto 0);

    type Ped_FIFO_filling_machine is
        (
            Ped_FIFO_filling_machine_is_idle,
            Ped_FIFO_filling
        );
    signal next_state : Ped_FIFO_filling_machine := Ped_FIFO_filling_machine_is_idle;

begin



    U1 :  PedFIFO 
        PORT MAP (
            CLK                       => clk,   
            RST                       => PedFIFO_rst,   
            WR_EN 		                => PedFIFO_wr_en,   
            RD_EN                     => PedFIFO_rd_en,   
            DIN                       => PedFIFO_din,   
            DOUT                      => PedFIFO_dout,   
            FULL                      => PedFIFO_full,   
            EMPTY                     => PedFIFO_empty   
        );

    U2 :  waveFIFO 
        PORT MAP (
            CLK                       => clk_i,   --add
            RST                       => rst,   --add
            WR_EN 		                => wr_en,   --add
            RD_EN                     => rd_en,   --add
            DIN                       => din,   --add
            DOUT                      => dout,   --add
            FULL                      => full,   --add
            EMPTY                     => empty   --add
        );

    U3 : SubtractPedestals
        port map (
            clk                              =>   clk,
            WaveAndPedFIFOsReady             =>   WaveAndPedFIFOsReady,
            PacketSize                       =>   PacketSize,
            interupt                         =>   interupt,
            busy                             =>   busy,
            done                             =>   done,
            PedestalSubtractedWaveforms_Out  =>   PedestalSubtractedWaveforms_Out
        );

    U4 : ExtractFeatures
        port map (
            clk                          =>   clk,
            PedestalSubtractedWaveforms  =>   PedestalSubtractedWaveforms,
            enable                       =>   enable,
            busy                         =>   busy,
            done                         =>   done,
            interupt                     =>   interupt,
            reset                        =>   reset 
        );

	  process(clk) begin
		    if (rising_edge(clk)) then
          case next_state is

              when Ped_FIFO_filling_machine_is_idle =>
                  if PedFIFO_wr_ena = "1" then
                      internal_PedestalData_In <= PedestalData_In;
                      PedFIFO_din <= PedestalData_In(11 downto 0);
                      next_state <= Ped_FIFO_is_filling;
                  else
                      next_state <= Ped_FIFO_filling_machine_is_idle;
                  end if;
      
              when Ped_FIFO_is_filling =>
                PedFIFO_din <= internal_PedestalData_In(23 downto 12);
                next_state <= Ped_FIFO_filling_machine_is_idle;
      
          end case;
      end if;
  end process;

end Behavioral;

