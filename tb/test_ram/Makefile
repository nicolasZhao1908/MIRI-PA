SIM=verilator
TOPLEVEL_LANG=verilog
PWD=$(shell pwd)
ROOT_DIR=$(PWD)/../..
TB_DIR=$(ROOT_DIR)/tb
RTL_DIR=$(ROOT_DIR)/rtl

export PYTHONPATH:=$(TB_DIR)/models:$(PYTHONPATH)
VERILOG_SOURCES=$(RTL_DIR)/ram.sv

EXTRA_ARGS+=--trace-fst --trace-structs -I$(RTL_DIR)

TOPLEVEL=ram
MODULE=test_ram

include $(shell cocotb-config --makefiles)/Makefile.sim