TARGETS := tb/test_arbiter \
		tb/test_regfile \
		tb/test_mem \
		tb/test_fetch \
		tb/test_cache \
		tb/test_cache_top \
		tb/test_stb \
		tb/test_core_top
CORETB := tb/test_core_top


all: $(TARGETS)

$(TARGETS):
	$(MAKE) -C $@

core: 
	$(MAKE) -C $(CORETB)
	$(MAKE) wave

wave: tb/test_core_top/dump.fst tb/test_core_top/waves.tcl
	gtkwave $< --script=$(word 2,$^)

clean:
	rm -rf **/*/__pycache__
	rm -rf **/*/results.xml
	rm -rf **/*/sim_build
	rm -rf **/*/dump.vcd
	rm -rf **/*/dump.fst

.PHONY: $(TARGETS) clean all wave core