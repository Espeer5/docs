################################################################################
#                                                                              #
#  MAKEFILE for CORDIC16 Design 											   #
#                                                                              #
#  This makefil offers two targets, 'plot', and 'clean'. The former runs all   #
#  tests for the CORDIC16 module and plots the outputs using Python, and the   #
#  latter removes all files generated by the tests.                            #
#                                                                              #
#  Revision History:                                                           #
#      12/8/24  Edward Speer  Initial Revision								   #
#                                                                              #
################################################################################

################################################################################
#  CONSTANTS																   #
################################################################################

# List of PNG output plots
PLOTS = cordic16_cos.png cordic_16_sin.png cordic16_cosh.png cordic16_sinh.png \
        cordic16_mul.png cordic16_div.png

################################################################################
#  TARGETS   																   #
################################################################################

# Default target
.PHONY: plot
plot: res.txt $(PLOTS)

# Rule to generate test output
res.txt: AddSub1.vhd XYCell.vhd XYZRow.vhd CORDIC16_TB.vhd CORDIC16.vhd
	@echo "Generating CORDIC test output..."
	ghdl -a --work=CORDIC16 AddSub1.vhd XYCell.vhd XYZRow.vhd CORDIC16.vhd \
	                        CORDIC16_TB.vhd
	ghdl -e --work=CORDIC16 TESTBENCH_FOR_CORDIC16_IMPLEMENTATION
	ghdl -r --work=CORDIC16 TESTBENCH_FOR_CORDIC16_IMPLEMENTATION > res.txt

# Plot test output using Python script
$(PLOTS): res.txt plt.py
	@echo "Plotting CORDIC test output..."
	python3 plt.py

# Clean up generated files
.PHONY: clean
clean:
	@echo "Cleaning up..."
	rm -f res.txt $(PLOTS)
