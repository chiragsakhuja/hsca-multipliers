all: counters adders mults
test: test-counters test-adders

counters:
	iverilog -o counters_tb -Wall counters.v counters_tb.v

test-counters: counters
	./counters_tb

adders:
	iverilog -o adders_tb -Wall adders.v adders_tb.v

test-adders: adders
	./adders_tb

mults:
	g++ -g -Wall mult_gen.cpp -o mult_gen
	./mult_gen 4 0 > mult_3_2.v
	iverilog -o mult_3_2_tb -Wall mult_3_2.v counters.v mult_3_2_tb.v

clean:
	rm counters_tb adders_tb mult_3_2_tb
