TESTS := tb/test_arbiter \
		tb/test_regfile \
		tb/test_memory \
		tb/test_fetch \
		tb/test_cache \
		tb/test_dcache \
		tb/test_stb \
		tb/test_core_top

.PHONY: $(TESTS) clean all

all: $(TESTS)

$(TESTS):
	@cd $@ && $(MAKE)

clean:
	$(foreach TEST, $(TESTS), $(MAKE) -C $(TEST) clean;)
