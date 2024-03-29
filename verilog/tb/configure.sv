package configure;
  timeunit 1ns;
  timeprecision 1ps;

  parameter mul_performance = 1;

  parameter buffer_depth = 8;

  parameter bram_cycle = 0;
  parameter bram_depth = 262144;

  parameter rom_base_addr = 32'h0;
  parameter rom_top_addr  = 32'h80;

  parameter print_base_addr = 32'h1000000;
  parameter print_top_addr  = 32'h1000004;

  parameter clint_base_addr = 32'h2000000;
  parameter clint_top_addr  = 32'h200C000;

  parameter bram_base_addr = 32'h80000000;
  parameter bram_top_addr  = 32'h90000000;

  parameter clk_freq = 1000000000; // 1GHz
  parameter rtc_freq = 100000000; // 100MHz

  parameter clk_divider_rtc = (clk_freq/rtc_freq)/2-1;

endpackage
