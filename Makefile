PROGDIR = programs
GTKWAVE = gtkwave

PWD=$(shell pwd)

VERILOG_SRCS = $(shell find rtl -name *.v -o -name *.sv )
INC=$(PWD)/rtl/inc

SIMFILE=sim_top.cpp
VERILATOR ?= verilator
VERILATOR_FLAGS = -O3 --timescale  1ns/1ps \
				  --trace-fst --trace-structs \
				  --trace-max-array 262144


sim: $(VERILOG_SRCS) $(SIMFILE)
	$(MAKE) -C $(PROGDIR) $(PROG)
	$(VERILATOR) $(VERILATOR_FLAGS) -I$(INC) --top-module top --cc  --exe  $^
	$(MAKE) -j4 -C obj_dir -f Vtop.mk Vtop
	obj_dir/Vtop -t

lint:
	verilator --lint-only -I$(INC) --top-module top $(VERILOG_SRCS)

waves: wave.fst waves.tcl
	$(GTKWAVE) $< --script=$(word 2,$^) > /dev/null 2>&1 &

clean:
	rm -rf obj_dir
	rm -rf **/*/__pycache__
	rm -rf **/*/results.xml
	rm -rf **/*/sim_build
	rm -rf **/*/dump.vcd
	rm -rf **/*/dump.fst

.PHONY: $(TARGETS) clean waves sim lint
