TARGETS := tb/test_arbiter \
		tb/test_regfile \
		tb/test_mem \
		tb/test_fetch \
		tb/test_cache \
		tb/test_cache_top \
		tb/test_stb \
		tb/test_core_top
CORETB := tb/test_core_top
PROGDIR = programs
GTKWAVE = gtkwave


all: $(TARGETS)

$(TARGETS):
	$(MAKE) -C $@

core: 
	$(MAKE) -C $(PROGDIR) $(PROG)
	$(MAKE) -C $(CORETB)

waves: tb/test_core_top/dump.fst tb/test_core_top/waves.tcl
	$(GTKWAVE) $< --script=$(word 2,$^) > /dev/null 2>&1 &

clean:
	rm -rf **/*/__pycache__
	rm -rf **/*/results.xml
	rm -rf **/*/sim_build
	rm -rf **/*/dump.vcd
	rm -rf **/*/dump.fst

.PHONY: $(TARGETS) clean all wave core
