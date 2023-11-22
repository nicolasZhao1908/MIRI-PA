SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_INCLUDE_DIRS += $(PWD)/rtl
VERILOG_SOURCES += $(PWD)/rtl/cache/dcache.sv

#SIM_ARGS = -Wno{MODDUP}

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = dcache_mem_testonly

# MODULE is the basename of the Python test file
MODULE = tb.test_cache.test_dcache

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim