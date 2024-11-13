#!/bin/bash
#==============================================================================#
#                                                                              #
#  runtests.bash                                                               #
#                                                                              #
#  This script is used to compile and run all of the VHDL test benches         #
#  associated with the PWM Audio player system. This script leverages GHDL     #
#  to compile the VHDL code and execute the test benches.                      #
#                                                                              #
#  Revision History:                                                           #
#      11/11/2024  Edward Speer  Initial Revision                              #
#      11/12/2024  Edward Speer  Include implementation architecture tests     #
#                                                                              #
#==============================================================================#

# Set the working directory to the location of this script
cd "$(dirname "$0")"

# Begin with the 32 MHz to 8 kHz clock divider block
printf "\n_-_-_-_-_-_M32_TO_K_8_CLOCK_DIV BLOCK TESTS_-_-_-_-_-_\n"
echo "Compiling VHDL code..."
ghdl -a --work=M32ToK8ClockDiv_TB M32ToK8ClockDiv.vhdl
ghdl -a --work=M32ToK8ClockDiv_TB M32ToK8ClockDiv_TB.vhdl
echo "Testing behavioral simulation..."
ghdl -e --work=M32ToK8ClockDiv_TB TESTBENCH_FOR_M32ToK8ClockDiv_BEHAVIORAL
ghdl -r --work=M32ToK8ClockDiv_TB TESTBENCH_FOR_M32ToK8ClockDiv_BEHAVIORAL
echo "Testing implementation..."
ghdl -e --work=M32ToK8ClockDiv_TB TESTBENCH_FOR_M32ToK8ClockDiv_IMPLEMENTATION
ghdl -r --work=M32ToK8ClockDiv_TB TESTBENCH_FOR_M32ToK8ClockDiv_IMPLEMENTATION


# Next, compile and test the data address unit block
printf "\n_-_-_-_-_-_ADDR_UNIT BLOCK TESTS_-_-_-_-_-_\n"
echo "Compiling VHDL code..."
ghdl -a --work=AddrUnit_TB AddrUnit.vhdl
ghdl -a --work=AddrUnit_TB AddrUnit_TB.vhdl
echo "Testing behavioral simulation..."
ghdl -e --work=AddrUnit_TB TESTBENCH_FOR_AddrUnit_BEHAVIORAL
ghdl -r --work=AddrUnit_TB TESTBENCH_FOR_AddrUnit_BEHAVIORAL
echo "Testing implementation..."
ghdl -e --work=AddrUnit_TB TESTBENCH_FOR_AddrUnit_IMPLEMENTATION
ghdl -r --work=AddrUnit_TB TESTBENCH_FOR_AddrUnit_IMPLEMENTATION

# Next, the button press decoding logic
printf "\n_-_-_-_-_-_BTN4_DECODER BLOCK TESTS_-_-_-_-_-_\n"
echo "Compiling VHDL code..."
ghdl -a --work=Btn4Decoder_TB Btn4Decoder.vhdl
ghdl -a --work=Btn4Decoder_TB Btn4Decoder_TB.vhdl
echo "Testing behavioral simulation..."
ghdl -e --work=Btn4Decoder_TB TESTBENCH_FOR_Btn4Decoder_BEHAVIORAL
ghdl -r --work=Btn4Decoder_TB TESTBENCH_FOR_Btn4Decoder_BEHAVIORAL
echo "Testing implementation..."
ghdl -e --work=Btn4Decoder_TB TESTBENCH_FOR_Btn4Decoder_IMPLEMENTATION
ghdl -r --work=Btn4Decoder_TB TESTBENCH_FOR_Btn4Decoder_IMPLEMENTATION

# Now the PWM output driver
printf "\n_-_-_-_-_-_PWM_DRIVER BLOCK TESTS_-_-_-_-_-_\n"
echo "Compiling VHDL code..."
ghdl -a --work=PwmDriver_TB PwmDriver.vhdl
ghdl -a --work=PwmDriver_TB PwmDriver_TB.vhdl
echo "Testing behavioral simulation..."
ghdl -e --work=PwmDriver_TB TESTBENCH_FOR_PwmDriver_BEHAVIORAL
ghdl -r --work=PwmDriver_TB TESTBENCH_FOR_PwmDriver_BEHAVIORAL  \
                            | grep -vF "(assertion warning): NUMERIC_STD.\"<\":"
echo "Testing implementation..."
ghdl -e --work=PwmDriver_TB TESTBENCH_FOR_PwmDriver_IMPLEMENTATION
ghdl -r --work=PwmDriver_TB TESTBENCH_FOR_PwmDriver_IMPLEMENTATION  \
                            | grep -vF "(assertion warning): NUMERIC_STD.\"<\":"

# Attempt to compile the top=level design
printf "\n_-_-_-_-_-_PWM_AUDIO_PLAYER BLOCK TESTS_-_-_-_-_-_\n"
echo "Compiling VHDL code..."
ghdl -a --work=PwmAudioPlayer M32ToK8ClockDiv.vhdl
ghdl -a --work=PwmAudioPlayer AddrUnit.vhdl
ghdl -a --work=PwmAudioPlayer Btn4Decoder.vhdl
ghdl -a --work=PwmAudioPlayer PwmDriver.vhdl
ghdl -a --work=PwmAudioPlayer PwmAudioPlayer.vhdl
ghdl -e --work=PwmAudioPlayer PWMAudioPlayer_IMPLEMENTATION

# Done with tests
printf "\nAll tests complete."
