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

VERILOG_SOURCES=$(RTL_DIR)/core_top.sv \
				$(RTL_DIR)/core.sv \
				$(RTL_DIR)/utils/hazard.sv \
				$(RTL_DIR)/utils/forward.sv \
				$(RTL_DIR)/utils/arbiter.sv \
 				$(RTL_DIR)/utils/brisc_pkg.svh \
				$(RTL_DIR)/utils/memory.sv \
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
 				$(RTL_DIR)/wb/wb_stage.sv 

EXTRA_ARGS+=--trace-fst --trace-structs $(IARG) --trace-max-array 16384 

TOPLEVEL=core_top
MODULE=test_core_top

include $(shell cocotb-config --makefiles)/Makefile.sim