SIM=verilator
TOPLEVEL_LANG=verilog
PWD=$(shell pwd)
ROOT_DIR=$(PWD)/../..
TB_DIR=$(ROOT_DIR)/tb
RTL_DIR=$(ROOT_DIR)/rtl

export PYTHONPATH:=$(TB_DIR)/models:$(PYTHONPATH)
VERILOG_SOURCES=$(RTL_DIR)/cache/dcache.sv

#FAILED SEED = 1701257810
#FS_2 = 1700914942

EXTRA_ARGS+=--trace-fst --trace-structs -I$(RTL_DIR)
TOPLEVEL=two_caches_arbiter_testonly
MODULE=test_arbiter

include $(shell cocotb-config --makefiles)/Makefile.sim