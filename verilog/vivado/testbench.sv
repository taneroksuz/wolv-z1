import configure::*;

module testbench;

  timeunit 1ns;
  timeprecision 1ps;

  logic rst;
  logic clk;
  logic rx;
  logic tx;

  initial begin
    rst = 1;
    clk = 1;
    rx = 1;
    tx = 1;
  end

  always begin
    #100;
    clk = !clk;
  end

  always begin
    #20;
    clk = !clk;
  end

  top_cpu top_cpu_comp
  (
    .rst (rst),
    .clk (clk),
    .rx (rx),
    .tx (tx)
  );

endmodule
