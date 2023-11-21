SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_INCLUDE_DIRS += $(PWD)/rtl
VERILOG_SOURCES += $(PWD)/rtl/arithmatic/adder.sv


# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = add_sub

# MODULE is the basename of the Python test file
MODULE = tb.test_arithmatic.test_adder

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim