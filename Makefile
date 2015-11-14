counters:
	iverilog -o counters_tb counters.v counters_tb.v

test_counters: counters
	./counters_tb

clean:
	rm counters_tb
