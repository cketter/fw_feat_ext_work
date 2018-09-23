----------------------------------------------------------------------------------
-- Company:       University of Hawaii at Manoa
-- Engineer:      Chris Ketter
-- 
-- Create Date:    10:54:53 09/21/2018 
-- Design Name:    
-- Module Name:    ProcessTriggersAndWaveforms - Behavioral 
-- Project Name:   KLM Scnitillator Readout
-- Target Devices: XC6SLX150T
-- Tool versions: 
-- Description: 
--      The job of this module is to instantiate all the modules needed for 
--  waveform processing and feature extraction. When a global trigger is 
--  recieved, the TriggerQueue module will check the trigger stream and look
--  for matching hits. It will watch the flow of data, and as soon as resources
--  become available, it will trigger a readout of the TX ASIC then immediately
--  generate a channel mask (to discard retundant channels which are read in 
--  in parallel to channels of interest) and a stream of address for fetching
--  pedestal values from external SRAM. Both waveform and pedestal data are then
--  staged in parallel FIFOs and fed to parallel pedestal subtraction modules.
--  Next the feature extraction algorithm is run on the pedestal subtracted
--  waveforms and features are written in their final hex format, staged in 
--  more parallel FIFOs. Finally, all of the hex packets are combined and sent
--  to the Aurora interface where the data finally leaves the FPGA on its way
--  to the KLM Data Concentrator.
--
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

entity ProcessTriggersAndWaveforms is
    Generic (
              MAX_NUM_CHANNELS_TO_READOUT : integer := 20
            );
    Port    ( 
              clk : in  STD_LOGIC;
              DataOut : out  STD_LOGIC_VECTOR(16 downto 0);
              GlobalTriggerIn : in  STD_LOGIC
            );
end ProcessTriggersAndWaveforms;


architecture Behavioral of ProcessTriggersAndWaveforms is

    --INTERNAL EVENT MASK SIGNALS
    signal ASICsToReadout   : STD_LOGIC_VECTOR(3 downto 0);
    signal EventChannelMask : STD_LOGIC_VECTOR(7 downto 0);



    signal PacketCombinerBusy        : STD_LOGIC_VECTOR(MAX_NUM_CHANNELS_TO_READOUT downto 0);
    signal EnablePacketCombiner      : STD_LOGIC_VECTOR(MAX_NUM_CHANNELS_TO_READOUT downto 0);


    COMPONENT TriggerQueue
        Port ( 
            clk              : in   STD_LOGIC;
            GlobalTriggerIn  : in   STD_LOGIC_VECTOR(11 downto 0);
            ASICsToReadout   : out  STD_LOGIC_VECTOR(3 downto 0);
            EventChannelMask : out  STD_LOGIC_VECTOR(7 downto 0)
        );
    END COMPONENT;


    COMPONENT PedFetchAddressStream
        Port ( 
            clk                        : in   STD_LOGIC;
            TriggeredChannelList_In    : in   STD_LOGIC_VECTOR (7 downto 0);
            SRAM_AddressStream_Out     : out  STD_LOGIC_VECTOR (21 downto 0)
        );
    END COMPONENT;


    COMPONENT TriggerTX_Readout
        Port ( 
            clk                 : in   STD_LOGIC;
            ASICsToReadout      : in   STD_LOGIC_VECTOR (3 downto 0);
            TriggerTX_Out       : out  STD_LOGIC_VECTOR (3 downto 0);
            busy                : out  STD_LOGIC;
            done                : out  STD_LOGIC
        );
    END COMPONENT;


    COMPONENT FetchPedestals
        Port ( 
            clk                     : in  STD_LOGIC;
            SRAM_AddressStream_In   : in  STD_LOGIC_VECTOR (21 downto 0);
            SRAM_AddressStream_Out  : out  STD_LOGIC_VECTOR (21 downto 0);
            busy                    : out  STD_LOGIC;
            done                    : out  STD_LOGIC
        );
    END COMPONENT;


    COMPONENT WaveformChannelFilter
        Port ( 
            clk               : in   STD_LOGIC;
            EventChannelMask  : in   STD_LOGIC_VECTOR (7 downto 0);
            WaveformData_In   : in   STD_LOGIC_VECTOR (11 downto 0);
            WaveformData_Out  : out  STD_LOGIC_VECTOR (11 downto 0);
            busy              : in   STD_LOGIC;
            done              : in   STD_LOGIC
        );
    END COMPONENT;


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


    COMPONENT CombinePackets
        Port ( 
            clk       : in   STD_LOGIC;
            enable    : in   STD_LOGIC;
            busy      : out  STD_LOGIC;
            done      : out  STD_LOGIC;
            DataOut   : out  STD_LOGIC_VECTOR (15 downto 0)
        );
    END COMPONENT;








begin

    U1 : TriggerQueue
        port map ( 
            clk              => clk             ,
            GlobalTriggerIn  => GlobalTriggerIn ,
            ASICsToReadout   => ASICsToReadout,
            EventChannelMask   => EventChannelMask
        );

    U2 : PedFetchAddressStream
        port map ( 
            clk                      =>   clk                     , 
            TriggeredChannelList_In  =>   TriggeredChannelList_In , 
            SRAM_AddressStream_Out   =>   SRAM_AddressStream_Out  
        );

    U3 : TriggerTX_Readout
        port map (
            clk                 =>     clk                 ,
            ASICsToReadout      =>     ASICsToReadout   ,
            TriggerTX_Out       =>     TriggerTX_Out       ,
            busy                =>     busy                ,
            done                =>     done                
        );

    U4 : WaveformChannelFilter
        port map (
            clk                =>    clk               ,
            EventChannelMask   =>    EventChannelMask  ,
            WaveformData_In    =>    WaveformData_In   ,
            WaveformData_Out   =>    WaveformData_Out  ,
            busy               =>    busy              ,
            done               =>    done              
        );

    U5 : FetchPedestals
        port map (
            clk                     =>   clk                     , 
            SRAM_AddressStream_In   =>   SRAM_AddressStream_In   , 
            SRAM_AddressStream_Out  =>   SRAM_AddressStream_Out  , 
            busy                    =>   busy                    , 
            done                    =>   done                    
        );

    U6 : for i in 0 to MAX_NUM_CHANNELS_TO_READOUT generate
        SubtractPedestals_i : SubtractPedestals
            port map (
                clk                              =>   clk,
                WaveAndPedFIFOsReady             =>   WaveAndPedFIFOsReady(i),
                PacketSize                       =>   PacketSize(i),
                interupt                         =>   interupt(i),
                busy                             =>   busy(i),
                done                             =>   done(i),
                PedestalSubtractedWaveforms_Out  =>   PedestalSubtractedWaveforms_Out(i) 
            );
        end generate;

    U7 : for i in 0 to MAX_NUM_CHANNELS_TO_READOUT generate
        ExtractFeatures_i : ExtractFeatures
            port map (
                clk                          =>   clk,
                PedestalSubtractedWaveforms  =>   PedestalSubtractedWaveforms(i),
                enable                       =>   enable(i),
                busy                         =>   busy(i),
                done                         =>   done(i),
                interupt                     =>   interupt(i),
                reset                        =>   reset(i) 
            );
        end generate;

    U8 : CombinePackets
        port map (
            clk      =>    clk       , 
            enable   =>    enable    , 
            busy     =>    busy      , 
            done     =>    done      , 
            DataOut  =>    DataOut   
        );



end Behavioral;



