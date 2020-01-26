import wires::*;

module register
(
  input logic rst,
  input logic clk,
  input register_in_type register_in,
  output register_out_type register_out
);

  logic [31:0] reg_file[0:31];

  initial begin
    reg_file = '{default:'0};
  end

  always_comb begin
    if (register_in.rden1 == 1) begin
      register_out.rdata1 = reg_file[register_in.raddr1];
    end else begin
      register_out.rdata1 = 32'h0;
    end
    if (register_in.rden2 == 1) begin
      register_out.rdata2 = reg_file[register_in.raddr2];
    end else begin
      register_out.rdata2 = 32'h0;
    end
  end

  always_ff @(posedge clk) begin
    if (register_in.wren == 1 && register_in.waddr != 0) begin
      reg_file[register_in.waddr] <= register_in.wdata;
    end
  end

endmodule
