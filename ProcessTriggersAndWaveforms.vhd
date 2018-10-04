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
constant MAX_NUM_CHANNELS_TO_READOUT : integer :=20;
type hit_map is array (0 to MAX_NUM_CHANNELS_TO_READOUT - 1) of std_logic_vector(7 downto 0); --first define the type of array.
type hit_record is
    record
        asic_and_ch : hit_map; --hit.asic_ch(hitNo) returns slv("4bit asic" & "4bit ch")
        win_start   : std_logic_vector(8 downto 0); --hit.win_start returns slv("9bit window")
        hit_count   : integer;
    end record

entity ProcessTriggersAndWaveforms is
    Port    ( 
              main_clk : in  STD_LOGIC;
              main_DataOut : out  STD_LOGIC_VECTOR(16 downto 0);
              main_TriggerIn : in hit_record
            );
end ProcessTriggersAndWaveforms;


architecture Behavioral of ProcessTriggersAndWaveforms is

    --INTERNAL EVENT MASK SIGNALS
    signal internal_QueuedTrigger             : hit_record;
    --INTERNAL STATUS SIGNALS
    signal internal_TXReadoutBusy             : STD_LOGIC;
    signal internal_PedFifosEmpty             : std_logic_vector(MAX_NUM_CHANNELS_TO_READOUT downto 0);
    signal internal_waveFifosEmpty            : std_logic_vector(MAX_NUM_CHANNELS_TO_READOUT downto 0);
    signal internal_PacketCombinerBusy        : STD_LOGIC_VECTOR(MAX_NUM_CHANNELS_TO_READOUT downto 0);
    signal internal_EnablePacketCombiner      : STD_LOGIC_VECTOR(MAX_NUM_CHANNELS_TO_READOUT downto 0);
    signal internal_PedestalData              : std_logic_vector(23 downto 0);

    COMPONENT TriggerQueue
        Port ( 
            clk              : in   STD_LOGIC;
            -- Trigger Inputs
            TriggerIn          : in  hit_record;
            -- Process status flags
            TXReadoutBusy    : in  STD_LOGIC;
            PedFifosEmpty    : in  std_logic_vector(MAX_NUM_CHANNELS_TO_READOUT downto 0);
            waveFifosEmpty   : in  std_logic_vector(MAX_NUM_CHANNELS_TO_READOUT downto 0);
            -- Queued trigger outputs
            QueuedTriggerOut : out  hit_record;
            QueuedASICs      : out  STD_LOGIC_VECTOR(3 downto 0)
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


    COMPONENT EventPedestalFetcher
        Port ( 
            clk              : in   STD_LOGIC;
            enable           : in   STD_LOGIC;
            busy             : out  STD_LOGIC;
            hit_index        : in   integer;
            TriggerIn        : in   hit_record;
            PedestalDataOut  : out  STD_LOGIC_VECTOR (23 downto 0)
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


    COMPONENT ParallelProcessing
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

    type Pedestal_Fetching_Management is
        (
            idle,
            fetching_ith_channel
        );
    signal next_fetch_state : Pedestal_Fetching_Management := idle;
    signal count : integer := 0;



begin

    U1 : TriggerQueue
        port map ( 
            clk               => main_clk,
            TriggerIn         => main_TriggerIn,
            QueuedTriggerOut  => internal_QueuedTrigger,
            CycleQueueFlag    => internal_CycleQueueFlag
        );

    U2 : EventPedestalFetcher
        port map ( 
            clk              => clk,            
            enable           => internal_PedFetchEnable,
            busy             => internal_PedFetchBusy,
            hit_index        => int_hit_index,
            TriggerIn        => internal_QueuedTrigger,
            PedestalDataOut  => internal_PedestalData
        );

	  process(clk) begin
		    if (rising_edge(clk)) then
			      case next_fetch_state is
          
                when idle =>
                    if expression then
                        count <= "0";
                        next_fetch_state <= fetching_ith_channel;
                    else
                        next_fetch_state <= idle;
                    end if;

                when fetching_ith_channel =>
                    if count < internal_QueuedTrigger.hit_count then
                        internal_PedFetchEnable <= "1";
                        int_hit_index <= count;
                        next_fetch_state <= wait_for_ith_channel_fetch;
                    else
                        next_fetch_state <= idle;
                    end if;

                when wait_for_ith_channel_fetch =>
                    if internal_PedFetchBusy = "1" then
                        next_fetch_state <= wait_for_ith_channel_fetch;
                    else 
                        count <= count +1;
                        next_fetch_state <= fetching_ith_channel;
                    end if;

            end case;
        end if;
    end process;

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
            clk                =>    clk,
            EventChannelMask   =>    EventChannelMask,
            WaveformData_In    =>    WaveformData_In,
            WaveformData_Out   =>    WaveformData_Out,
            busy               =>    busy,
            done               =>    done              
        );

    U5 : FetchPedestals
        port map (
            clk                     =>   clk, 
            SRAM_AddressStream_In   =>   SRAM_AddressStream_In, 
            SRAM_AddressStream_Out  =>   SRAM_AddressStream_Out, 
            busy                    =>   busy, 
            done                    =>   done                    
        );


    U9 : for i in 0 to MAX_NUM_CHANNELS_TO_READOUT generate
        ProcessWaveform_i : ParallelProcessing
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


    U10 : CombinePackets
        port map (
            clk      =>    clk, 
            enable   =>    enable, 
            busy     =>    busy, 
            done     =>    done, 
            DataOut  =>    DataOut   
        );



end Behavioral;






