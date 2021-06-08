import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic rst,
  input logic clk,
  input csr_out_type csr_out,
  input prefetch_out_type prefetch_out,
  output prefetch_in_type prefetch_in,
  input mem_out_type imem_out,
  output mem_in_type imem_in,
  input fetch_in_type d,
  output fetch_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  fetch_reg_type r,rin;
  fetch_reg_type v;

  always_comb begin

    v = r;

    v.valid = ~(d.d.stall | d.e.stall | d.e.clear);
    v.stall = prefetch_out.stall | d.d.stall | d.e.stall | d.e.clear;
    v.clear = csr_out.exception | csr_out.mret | d.e.clear;
    v.spec = csr_out.exception | csr_out.mret | d.d.jump | d.e.clear;

    v.instr = prefetch_out.instr;

    if (csr_out.exception == 1) begin
      v.pc = csr_out.mtvec;
    end else if (csr_out.mret == 1) begin
      v.pc = csr_out.mepc;
    end else if (d.d.jump == 1) begin
      v.pc = d.d.address;
    end else if (v.stall == 0) begin
      v.pc = v.pc + ((v.instr[1:0] == 2'b11) ? 4 : 2);
    end

    prefetch_in.pc = r.pc;
    prefetch_in.npc = v.pc;
    prefetch_in.spec = v.spec;
    prefetch_in.valid = v.valid;
    prefetch_in.fence = d.d.fence;
    prefetch_in.rdata = imem_out.mem_rdata;
    prefetch_in.ready = imem_out.mem_ready;

    imem_in.mem_valid = 1;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = prefetch_out.fpc;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    rin = v;

    q.pc = r.pc;
    q.instr = v.instr;
    q.exception = r.exception;
    q.ecause = r.ecause;
    q.etval = r.etval;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
