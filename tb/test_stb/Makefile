SIM=verilator
TOPLEVEL_LANG=verilog
PWD=$(shell pwd)
ROOT_DIR=$(PWD)/../..
TB_DIR=$(ROOT_DIR)/tb
RTL_DIR=$(ROOT_DIR)/rtl
INC=$(RTL_DIR)/inc

export PYTHONPATH:=$(TB_DIR)/models:$(PYTHONPATH)
VERILOG_SOURCES=$(RTL_DIR)/cache/store_buffer.sv

EXTRA_ARGS+=--trace-fst --trace-structs -I$(INC)

TOPLEVEL=store_buffer
MODULE=test_stb

include $(shell cocotb-config --makefiles)/Makefile.sim