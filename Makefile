TESTS := tb/test_control \
		tb/test_adder \
		tb/test_dcache \
		tb/test_arbiter

.PHONY: $(TESTS) clean all

all: $(TESTS)

$(TESTS):
	@cd $@ && $(MAKE)

clean:
	$(foreach TEST, $(TESTS), $(MAKE) -C $(TEST) clean;)