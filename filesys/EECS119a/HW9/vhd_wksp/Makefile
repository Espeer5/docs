# Define target 'test' = all tests
test: AddSub1 XYCell XYZRow CORDIC16

# Define the target 'AddSub1' to test AddSub1 module
AddSub1:
	@echo "TESTING ADDSUB1"
	@ghdl -a --work=AddSub1 AddSub1.vhd
	@ghdl -a --work=AddSub1 AddSub1_TB.vhd
	@ghdl -e --work=AddSub1 TESTBENCH_FOR_ADDSUB1_IMPLEMENTATION
	@ghdl -r --work=AddSub1 TESTBENCH_FOR_ADDSUB1_IMPLEMENTATION --vcd=AddSub1.vcd
	@echo "TESTING ADDSUB1 COMPLETED"


# # Define the target 'XYCell' to test XYCell module
# XYCell:
# 	@echo "TESTING XYCELL"
# 	@ghdl -a --work=XYCell AddSub1.vhd
# 	@ghdl -a --work=XYCell XYCell.vhd
# 	@ghdl -a --work=XYCell XYCell_TB.vhd
# 	@ghdl -e --work=XYCell TESTBENCH_FOR_XYCELL_DATAFLOW
# 	@ghdl -r --work=XYCell TESTBENCH_FOR_XYCELL_DATAFLOW --vcd=XYCell.vcd
# 	@echo "TESTING XYCELL COMPLETED"

# Define the target 'XYZRow' to test XYZRow module
# XYZRow:
# 	@echo "TESTING XYZROW"
# 	@ghdl -a --work=XYZRow AddSub1.vhd
# 	@ghdl -a --work=XYZRow XYCell.vhd
# 	@ghdl -a --work=XYZRow XYZRow.vhd
# 	@ghdl -a --work=XYZRow XYZRow_TB.vhd
# 	@ghdl -e --work=XYZRow TESTBENCH_FOR_XYZROW_DATAFLOW
# 	@ghdl -r --work=XYZRow TESTBENCH_FOR_XYZROW_DATAFLOW --vcd=XYZRow.vcd
# 	@echo "TESTING XYZROW COMPLETED"

# Define the target 'CORDIC16' to test CORDIC16 module
CORDIC16:
	@echo "TESTING CORDIC16"
	@ghdl -a --work=CORDIC16 AddSub1.vhd
	@ghdl -a --work=CORDIC16 XYCell.vhd
	@ghdl -a --work=CORDIC16 XYZRow.vhd
	@ghdl -a --work=CORDIC16 CORDIC16.vhd
	@ghdl -a --work=CORDIC16 CORDIC16_TB.vhd
	@ghdl -e --work=CORDIC16 TESTBENCH_FOR_CORDIC16_IMPLEMENTATION
	@ghdl -r --work=CORDIC16 TESTBENCH_FOR_CORDIC16_IMPLEMENTATION --vcd=CORDIC16.vcd
	@echo "TESTING CORDIC16 COMPLETED"

# None of these tests produce output files
.PHONY: test AddSub1 XYCell XYZRow CORDIC16