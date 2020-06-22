import configure::*;

module top_cpu
(
  input logic rst,
  input logic clk,
  input logic rx,
  output logic tx
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0  : 0] memory_valid;
  logic [0  : 0] memory_instr;
  logic [31 : 0] memory_addr;
  logic [31 : 0] memory_wdata;
  logic [3  : 0] memory_wstrb;
  logic [31 : 0] memory_rdata;
  logic [0  : 0] memory_ready;

  logic [0  : 0] bram_valid;
  logic [0  : 0] bram_instr;
  logic [31 : 0] bram_addr;
  logic [31 : 0] bram_wdata;
  logic [3  : 0] bram_wstrb;
  logic [31 : 0] bram_rdata;
  logic [0  : 0] bram_ready;

  logic [0  : 0] uart_valid;
  logic [0  : 0] uart_instr;
  logic [31 : 0] uart_addr;
  logic [31 : 0] uart_wdata;
  logic [3  : 0] uart_wstrb;
  logic [31 : 0] uart_rdata;
  logic [0  : 0] uart_ready;

  always_comb begin

    if (memory_addr == uart_base_addr) begin
      bram_valid = 0;
      uart_valid = memory_valid;
    end else begin
      bram_valid = memory_valid;
      uart_valid = 0;
    end

    uart_instr = memory_instr;
    uart_addr = memory_addr;
    uart_wdata = memory_wdata;
    uart_wstrb = memory_wstrb;

    bram_instr = memory_instr;
    bram_addr = memory_addr;
    bram_wdata = memory_wdata;
    bram_wstrb = memory_wstrb;

    if (bram_ready == 1) begin
      memory_rdata = bram_rdata;
      memory_ready = bram_ready;
    end else if  (uart_ready == 1) begin
      memory_rdata = uart_rdata;
      memory_ready = uart_ready;
    end else begin
      memory_rdata = 0;
      memory_ready = 0;
    end

  end

  cpu cpu_comp
  (
    .rst (rst),
    .clk (clk),
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_ready (memory_ready)
  );

  bram bram_comp
  (
    .rst (rst),
    .clk (clk),
    .bram_valid (bram_valid),
    .bram_instr (bram_instr),
    .bram_addr (bram_addr),
    .bram_wdata (bram_wdata),
    .bram_wstrb (bram_wstrb),
    .bram_rdata (bram_rdata),
    .bram_ready (bram_ready)
  );

  uart uart_comp
  (
    .rst (rst),
    .clk (clk),
    .uart_valid (uart_valid),
    .uart_instr (uart_instr),
    .uart_addr (uart_addr),
    .uart_wdata (uart_wdata),
    .uart_wstrb (uart_wstrb),
    .uart_rdata (uart_rdata),
    .uart_ready (uart_ready),
    .uart_rx (rx),
    .uart_tx (tx)
  );

endmodule
