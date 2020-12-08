import configure::*;

module testbench;

  timeunit 1ns;
  timeprecision 1ps;

  logic rst;
  logic clk;
  logic rx;
  logic tx;

  initial begin
    rst = 0;
    clk = 0;
    rx = 0;
    #20;
    rst = 1;
  end

  always begin
    #5;
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
