# Define the target 'test'
test:
	@echo "Compiling VHDL files..."
	@ghdl -a --work=Div16 Div16.vhd
	@ghdl -a --work=Div16 Div16_TB.vhd
	@ghdl -e --work=Div16 TESTBENCH_FOR_DIV16_IMPLEMENTATION

	@echo "Running simulation..."
	@ghdl -r --work=Div16 TESTBENCH_FOR_DIV16_IMPLEMENTATION

# Test is not an output file
.PHONY: test
