SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_INCLUDE_DIRS += $(PWD)/rtl
VERILOG_SOURCES += $(PWD)/rtl/control.sv
#SIM_ARGS += -g2012

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = control

# MODULE is the basename of the Python test file
MODULE = tb.test_control

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
