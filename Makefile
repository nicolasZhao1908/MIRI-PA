TARGETS := tb/test_arbiter \
		tb/test_regfile \
		tb/test_mem \
		tb/test_fetch \
		tb/test_cache \
		tb/test_cache_top \
		tb/test_stb \
		tb/test_core_top
PROGDIR = programs
GTKWAVE = gtkwave

PWD=$(shell pwd)
RTL_DIR=$(PWD)/rtl

IARG=-I$(RTL_DIR) \
	-I$(RTL_DIR)/utils \
	-I$(RTL_DIR)/cache \
	-I$(RTL_DIR)/alu \
	-I$(RTL_DIR)/decode \
	-I$(RTL_DIR)/fetch \
	-I$(RTL_DIR)/wb

VERILOG_SOURCES = $(shell find rtl -name *.v -o -name *.sv )
VERILATOR ?= verilator
VERILATOR_FLAGS = --report-unoptflat -O3 --timescale  1ns/1ps --trace-fst --trace-structs --trace-max-array 16384 $(IARG)

all: $(TARGETS)

$(TARGETS):
	$(MAKE) -C $@

SIMFILE=sim_top.cpp

core: $(VERILOG_SOURCES) $(SIMFILE)
	$(MAKE) -C $(PROGDIR) $(PROG)
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module top --cc  --exe  $^
	$(MAKE) -j -C obj_dir -f Vtop.mk Vtop
	obj_dir/Vtop -t


waves: wave.fst waves.tcl
	$(GTKWAVE) $< --script=$(word 2,$^) > /dev/null 2>&1 &

clean:
	rm -rf obj_dir
	rm -rf **/*/__pycache__
	rm -rf **/*/results.xml
	rm -rf **/*/sim_build
	rm -rf **/*/dump.vcd
	rm -rf **/*/dump.fst

cake:
	echo "            \`'.\n       .\`' \` * . \n      :  *  *|  :\n       ' |  || '\n        \`|~'||'\n        v~v~v~v\n        !@!@!@!\n       _!_!_!_!_\n      |  ||    ||\n      |  ||   |||\n      }{{{{}}}{{{\nejm97   __||__\n"

.PHONY: $(TARGETS) clean all wave core