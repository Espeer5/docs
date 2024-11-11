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
#                                                                              #
#==============================================================================#

# Set the working directory to the location of this script
cd "$(dirname "$0")"

# Begin with the 32 MHz to 8 kHz clock divider block
echo "Testing 32MHz to 8kHz clock divider block..."
ghdl -a --work=M32ToK8ClockDiv_TB M32ToK8ClockDiv.vhdl
ghdl -a --work=M32ToK8ClockDiv_TB M32ToK8ClockDiv_TB.vhdl
ghdl -e --work=M32ToK8ClockDiv_TB M32ToK8ClockDiv
ghdl -e --work=M32ToK8ClockDiv_TB M32ToK8ClockDiv_TB
ghdl -r --work=M32ToK8ClockDiv_TB M32ToK8ClockDiv_TB

# Next, compile and test the data address unit block
echo "Testing data address unit block..."
ghdl -a --work=AddrUnit_TB M32ToK8ClockDiv.vhdl
ghdl -a --work=AddrUnit_TB AddrUnit.vhdl
ghdl -a --work=AddrUnit_TB AddrUnit_TB.vhdl
ghdl -e --work=AddrUnit_TB M32ToK8ClockDiv
ghdl -e --work=AddrUnit_TB AddrUnit
ghdl -e --work=AddrUnit_TB AddrUnit_TB
ghdl -r --work=AddrUnit_TB AddrUnit_TB

# Next, the button press decoding logic
echo "Testing button press decoding logic..."
ghdl -a --work=Btn4Decoder_TB Btn4Decoder.vhdl
ghdl -a --work=Btn4Decoder_TB Btn4Decoder_TB.vhdl
ghdl -e --work=Btn4Decoder_TB Btn4Decoder
ghdl -e --work=Btn4Decoder_TB Btn4Decoder_TB
ghdl -r --work=Btn4Decoder_TB Btn4Decoder_TB

# Now the PWM output driver
echo "Testing PWM output driver..."
ghdl -a --work=PwmDriver_TB M32ToK8ClockDiv.vhdl
ghdl -a --work=PwmDriver_TB PwmDriver.vhdl
ghdl -a --work=PwmDriver_TB PwmDriver_TB.vhdl
ghdl -e --work=PwmDriver_TB M32ToK8ClockDiv
ghdl -e --work=PwmDriver_TB PwmDriver
ghdl -e --work=PwmDriver_TB PwmDriver_TB
ghdl -r --work=PwmDriver_TB PwmDriver_TB | grep -vF "(assertion warning): NUMERIC_STD.\"<\":"

# Attempt to compile the top=level design
echo "Testing top-level design..."
ghdl -a --work=PwmAudioPlayer M32ToK8ClockDiv.vhdl
ghdl -a --work=PwmAudioPlayer AddrUnit.vhdl
ghdl -a --work=PwmAudioPlayer Btn4Decoder.vhdl
ghdl -a --work=PwmAudioPlayer PwmDriver.vhdl
ghdl -a --work=PwmAudioPlayer PwmAudioPlayer.vhdl
ghdl -e --work=PwmAudioPlayer M32ToK8ClockDiv
ghdl -e --work=PwmAudioPlayer AddrUnit
ghdl -e --work=PwmAudioPlayer Btn4Decoder
ghdl -e --work=PwmAudioPlayer PwmDriver
ghdl -e --work=PwmAudioPlayer PwmAudioPlayer

# Done with tests
echo "All tests complete."
