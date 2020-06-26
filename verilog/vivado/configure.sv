package configure;
	timeunit 1ns;
	timeprecision 1ps;

	parameter start_base_addr = 32'h0;
	parameter uart_base_addr = 32'h100000;
	parameter timer_base_addr = 32'h200000;

	parameter prefetch_depth = 4;
	parameter bram_depth = 12;

	parameter clk_freq = 50000000; // 50MHz

	parameter baudrate = 115200;

	parameter clks_per_bit = clk_freq/baudrate;

endpackage
