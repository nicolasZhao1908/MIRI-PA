TESTS := tb/test_idecoder \
		tb/test_adder \
		tb/test_dcache \
		tb/test_arbiter \
		tb/test_regfile \
		tb/test_ram \
		tb/test_alu \
		tb/test_ifetch

.PHONY: $(TESTS) clean all

all: $(TESTS)

$(TESTS):
	@cd $@ && $(MAKE)

clean:
	$(foreach TEST, $(TESTS), $(MAKE) -C $(TEST) clean;)
