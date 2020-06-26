package configure;
	timeunit 1ns;
	timeprecision 1ps;

	parameter start_base_addr = 32'h0;
	parameter uart_base_addr = 32'h100000;

	parameter mtimecmp = 32'h200000;
	parameter mtimecmp4 = 32'h200004;
	parameter mtime = 32'h200008;
	parameter mtime4 = 32'h20000C;

	parameter prefetch_depth = 4;
	parameter bram_depth = 14;

endpackage
