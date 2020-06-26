package configure;
	timeunit 1ns;
	timeprecision 1ps;

	parameter start_base_addr = 32'h0;
	parameter uart_base_addr = 32'h100000;
	parameter timer_base_addr = 32'h200000;

	parameter prefetch_depth = 4;
	parameter bram_depth = 14;

endpackage
