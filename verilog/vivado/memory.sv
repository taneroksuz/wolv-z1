import configure::*;

module memory
(
  input logic rst,
  input logic clk,
  input logic [0   : 0] memory_valid,
  input logic [0   : 0] memory_instr,
  input logic [31  : 0] memory_addr,
  input logic [31  : 0] memory_wdata,
  input logic [3   : 0] memory_wstrb,
  output logic [31 : 0] memory_rdata,
  output logic [0  : 0] memory_ready
);

  logic [31 : 0] memory_block[0:2**memory_depth-1];

  logic [31 : 0] rdata;
  logic [0  : 0] ready;

  // initial begin
  //   $readmemh("memory.dat", memory_block, 0, 2**memory_depth-1);
  // end

  always_ff @(posedge clk) begin

    if (memory_valid == 1) begin

      if (memory_wstrb[0] == 1)
        memory_block[memory_addr[(memory_depth+1):2]][7:0] <= memory_wdata[7:0];
      if (memory_wstrb[1] == 1)
        memory_block[memory_addr[(memory_depth+1):2]][15:8] <= memory_wdata[15:8];
      if (memory_wstrb[2] == 1)
        memory_block[memory_addr[(memory_depth+1):2]][23:16] <= memory_wdata[23:16];
      if (memory_wstrb[3] == 1)
        memory_block[memory_addr[(memory_depth+1):2]][31:24] <= memory_wdata[31:24];

      rdata <= memory_block[memory_addr[(memory_depth+1):2]];
      ready <= 1;

    end else begin

      ready <= 0;

    end

  end

  assign memory_rdata = rdata;
  assign memory_ready = ready;


endmodule
