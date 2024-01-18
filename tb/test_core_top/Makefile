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
VERILOG_SOURCES= $(RTL_DIR)/brisc_pkg.svh \
				$(RTL_DIR)/core_top.sv \
				$(RTL_DIR)/core.sv \
				$(RTL_DIR)/hazard.sv \
				$(RTL_DIR)/arbiter.sv \
				$(RTL_DIR)/fetch/fetch_stage.sv \
				$(RTL_DIR)/decode/decode_stage.sv \
				$(RTL_DIR)/decode/ctrl.sv \
				$(RTL_DIR)/decode/regfile.sv \
				$(RTL_DIR)/alu/alu_stage.sv \
				$(RTL_DIR)/alu/alu.sv \
				$(RTL_DIR)/cache/cache_stage.sv \
 				$(RTL_DIR)/cache/cache_top.sv \
 				$(RTL_DIR)/cache/cache.sv \
 				$(RTL_DIR)/cache/store_buffer.sv \
 				$(RTL_DIR)/wb/wb_stage.sv \
				$(RTL_DIR)/utils/memory.sv \
				$(RTL_DIR)/utils/ff.sv \
				$(RTL_DIR)/utils/nff.sv

EXTRA_ARGS+=--trace-fst --trace-structs $(IARG)

TOPLEVEL=core_top
MODULE=test_core_top

include $(shell cocotb-config --makefiles)/Makefile.sim