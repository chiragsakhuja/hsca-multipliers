all: mults
test: test-counters test-adders test-mults

counters:
	iverilog -o counters_tb -Wall counters.v counters_tb.v

test-counters: counters
	./counters_tb

adders:
	iverilog -o adders_tb -Wall adders.v adders_tb.v

test-adders: adders
	./adders_tb

mults:
	g++ -O3 dadda_gen.cpp -o dadda_gen
	./dadda_gen mult_3_2.conf
	./dadda_gen mult_7_3.conf
	#iverilog -o mult_3_2_tb -Wall mult_3_2.v counters.v mult_3_2_tb.v
	iverilog -o mult_7_3_tb -Wall mult_7_3.v counters.v mult_7_3_tb.v

test-mults: mults
	#./mult_3_2_tb
	./mult_7_3_tb

clean:
	rm counters_tb adders_tb mult_3_2_tb dadda_gen
