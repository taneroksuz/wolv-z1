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

  task check;
    input logic [31 : 0] memory_block[0:2**memory_depth-1];
    input logic [31 : 0] memory_addr;
    input logic [31 : 0] memory_wdata;
    input logic [3  : 0] memory_wstrb;
    logic [0 : 0] ok;
    begin
      ok = 0;
      if (|memory_block[1024] == 0 & memory_addr[(memory_depth+1):2] == 1024  & |memory_wstrb == 1) begin
        ok = 1;
      end
      if (|memory_block[2048] == 0 & memory_addr[(memory_depth+1):2] == 2048  & |memory_wstrb == 1) begin
        ok = 1;
      end
      if (|memory_block[3072] == 0 & memory_addr[(memory_depth+1):2] == 3072  & |memory_wstrb == 1) begin
        ok = 1;
      end
      if (ok == 1) begin
        if (memory_wdata == 32'h1) begin
          $display("TEST SUCCEEDED");
        end else begin
          $display("TEST FAILED AT %d",memory_wdata);
        end
      end
    end
  endtask

  initial begin
    $readmemh("memory.dat", memory_block, 0, 2**memory_depth-1);
  end

  always_ff @(posedge clk) begin

    if (memory_valid == 1) begin

      check(memory_block,memory_addr,memory_wdata,memory_wstrb);

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
