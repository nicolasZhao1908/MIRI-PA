SIM=verilator
TOPLEVEL_LANG=verilog
PWD=$(shell pwd)
ROOT_DIR=$(PWD)/../..
TB_DIR=$(ROOT_DIR)/tb
RTL_DIR=$(ROOT_DIR)/rtl
IARG=-I$(RTL_DIR) \
	-I$(RTL_DIR)/utils \
	-I$(RTL_DIR)/cache \
	-I$(RTL_DIR)/alu \
	-I$(RTL_DIR)/decode \
	-I$(RTL_DIR)/fetch \
	-I$(RTL_DIR)/wb

export PYTHONPATH:=$(TB_DIR)/models:$(PYTHONPATH)
VERILOG_SOURCES += $(RTL_DIR)/utils/memory.sv

EXTRA_ARGS+=--trace-fst --trace-structs $(IARG) --trace-max-array 5000

#--trace-max-width <width>   Maximum array depth for tracing


TOPLEVEL = memory
MODULE = test_memory

include $(shell cocotb-config --makefiles)/Makefile.sim