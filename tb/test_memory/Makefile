SIM=verilator
TOPLEVEL_LANG=verilog
PWD=$(shell pwd)
ROOT_DIR=$(PWD)/../..
TB_DIR=$(ROOT_DIR)/tb
RTL_DIR=$(ROOT_DIR)/rtl
IARG=-I$(RTL_DIR) -I$(RTL_DIR)/utility -I$(RTL_DIR)/cache

export PYTHONPATH:=$(TB_DIR)/models:$(PYTHONPATH)
VERILOG_SOURCES += $(RTL_DIR)/utility/memory.sv

EXTRA_ARGS+=--trace-fst --trace-structs $(IARG) 


TOPLEVEL = memory
MODULE = test_memory

include $(shell cocotb-config --makefiles)/Makefile.sim