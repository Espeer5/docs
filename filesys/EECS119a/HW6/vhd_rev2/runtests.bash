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
#      11/14/2024  Edward Speer  Initial Revision                              #
#                                                                              #
#==============================================================================#

# Begin by compiling and testing the Cntr8ClockDiv block
printf "\n_-_-_-_-_-_Cntr8ClockDiv BLOCK TESTS_-_-_-_-_-_\n"
echo "Compiling VHDL code..."
ghdl -a --work=Cntr8ClockDiv_TB Cntr8ClockDiv.vhd
ghdl -a --work=Cntr8ClockDiv_TB Cntr8ClockDiv_TB.vhd
echo "Testing behavioral simulation..."
ghdl -e --work=Cntr8ClockDiv_TB TESTBENCH_FOR_Cntr8ClockDiv_BEHAVIORAL
ghdl -r --work=Cntr8ClockDiv_TB TESTBENCH_FOR_Cntr8ClockDiv_BEHAVIORAL
echo "Testing implementation simulation..."
ghdl -e --work=Cntr8ClockDiv_TB TESTBENCH_FOR_Cntr8ClockDiv_IMPLEMENTATION
ghdl -r --work=Cntr8ClockDiv_TB TESTBENCH_FOR_Cntr8ClockDiv_IMPLEMENTATION

# Next, test the PWMDriver block
printf "\n_-_-_-_-_-_PWMDriver BLOCK TESTS_-_-_-_-_-_\n"
echo "Compiling VHDL code..."
ghdl -a --work=PWMDriver_TB PWMDriver.vhd
ghdl -a --work=PWMDriver_TB PWMDriver_TB.vhd
echo "Testing behavioral simulation..."
ghdl -e --work=PWMDriver_TB TESTBENCH_FOR_PWMDriver_BEHAVIORAL
ghdl -r --work=PWMDriver_TB TESTBENCH_FOR_PWMDriver_BEHAVIORAL

# Finally, test the AddrUnit block
printf "\n_-_-_-_-_-_AddrUnit BLOCK TESTS_-_-_-_-_-_\n"
echo "Compiling VHDL code..."
ghdl -a --work=AddrUnit_TB AddrUnit.vhd
ghdl -a --work=AddrUnit_TB AddrUnit_TB.vhd
echo "Testing behavioral simulation..."
ghdl -e --work=AddrUnit_TB TESTBENCH_FOR_AddrUnit_BEHAVIORAL
ghdl -r --work=AddrUnit_TB TESTBENCH_FOR_AddrUnit_BEHAVIORAL
echo "Testing implementation simulation..."
ghdl -e --work=AddrUnit_TB TESTBENCH_FOR_AddrUnit_IMPLEMENTATION
ghdl -r --work=AddrUnit_TB TESTBENCH_FOR_AddrUnit_IMPLEMENTATION

# Compile the top-level design
printf "\n_-_-_-_-_-_TOP-LEVEL DESIGN TESTS_-_-_-_-_-_\n"
echo "Compiling VHDL code..."
ghdl -a --work=PwmAudioPlayer Cntr8ClockDiv.vhd
ghdl -a --work=PwmAudioPlayer AddrUnit.vhd
ghdl -a --work=PwmAudioPlayer PwmDriver.vhd
ghdl -a --work=PwmAudioPlayer PwmAudioPlayer.vhd

printf "\nAll tests complete."
