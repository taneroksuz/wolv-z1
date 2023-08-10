import constants::*;
import wires::*;

module execute_stage
(
  input logic reset,
  input logic clock,
  input alu_out_type alu_out,
  output alu_in_type alu_in,
  input lsu_out_type lsu_out,
  output lsu_in_type lsu_in,
  input csr_alu_out_type csr_alu_out,
  output csr_alu_in_type csr_alu_in,
  input div_out_type div_out,
  output div_in_type div_in,
  input mul_out_type mul_out,
  output mul_in_type mul_in,
  input bit_alu_out_type bit_alu_out,
  output bit_alu_in_type bit_alu_in,
  input bit_clmul_out_type bit_clmul_out,
  output bit_clmul_in_type bit_clmul_in,
  output register_write_in_type register_win,
  output forwarding_execute_in_type forwarding_ein,
  input csr_out_type csr_out,
  output csr_execute_in_type csr_ein,
  input mem_out_type dmem_out,
  input execute_in_type a,
  input execute_in_type d,
  output execute_out_type y,
  output execute_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  execute_reg_type r,rin;
  execute_reg_type v;

  always_comb begin

    v = r;

    v.instr = d.d.instr;

    if (d.e.stall == 1) begin
      v = r;
      v.instr.op = r.instr.op_b;
    end

    v.stall = 0;
    v.clear = csr_out.trap | csr_out.mret | d.e.clear;

    v.enable = ~(d.e.stall | v.clear);

    alu_in.rdata1 = v.instr.rdata1;
    alu_in.rdata2 = v.instr.rdata2;
    alu_in.imm = v.instr.imm;
    alu_in.sel = v.instr.op.rden2;
    alu_in.alu_op = v.instr.alu_op;

    v.instr.wdata = alu_out.result;

    bit_alu_in.rdata1 = v.instr.rdata1;
    bit_alu_in.rdata2 = v.instr.rdata2;
    bit_alu_in.imm = v.instr.imm;
    bit_alu_in.sel = v.instr.op.rden2;
    bit_alu_in.bit_op = v.instr.bit_op;

    v.instr.bdata = bit_alu_out.result;

    mul_in.rdata1 = v.instr.rdata1;
    mul_in.rdata2 = v.instr.rdata2;
    mul_in.enable = v.instr.op.mult & v.enable;
    mul_in.op = v.instr.mul_op;

    v.instr.mdata = mul_out.result;
    v.instr.mready = mul_out.ready;

    csr_alu_in.cdata = v.instr.crdata;
    csr_alu_in.rdata1 = v.instr.rdata1;
    csr_alu_in.imm = v.instr.imm;
    csr_alu_in.sel = v.instr.op.rden1;
    csr_alu_in.csr_op = v.instr.csr_op;

    v.instr.cwdata = csr_alu_out.cdata;

    div_in.rdata1 = v.instr.rdata1;
    div_in.rdata2 = v.instr.rdata2;
    div_in.enable = v.instr.op.division & v.enable;
    div_in.op = v.instr.div_op;

    v.instr.ddata = div_out.result;
    v.instr.dready = div_out.ready;

    bit_clmul_in.rdata1 = v.instr.rdata1;
    bit_clmul_in.rdata2 = v.instr.rdata2;
    bit_clmul_in.enable = v.instr.op.bitc & v.enable;
    bit_clmul_in.op = v.instr.bit_op.bit_zbc;

    v.instr.bcdata = bit_clmul_out.result;
    v.instr.bcready = bit_clmul_out.ready;

    lsu_in.ldata = dmem_out.mem_rdata;
    lsu_in.byteenable = v.instr.byteenable;
    lsu_in.lsu_op = v.instr.lsu_op;

    v.instr.ldata = lsu_out.result;

    if (v.instr.op.auipc == 1) begin
      v.instr.wdata = v.instr.address;
    end else if (v.instr.op.lui == 1) begin
      v.instr.wdata = v.instr.imm;
    end else if (v.instr.op.jal == 1) begin
      v.instr.wdata = v.instr.npc;
    end else if (v.instr.op.jalr == 1) begin
      v.instr.wdata = v.instr.npc;
    end else if (v.instr.op.crden == 1) begin
      v.instr.wdata = v.instr.crdata;
    end else if (v.instr.op.bitc == 1) begin
      v.instr.wdata = v.instr.bcdata;
    end else if (v.instr.op.bitm == 1) begin
      v.instr.wdata = v.instr.bdata;
    end else if (v.instr.op.mult == 1) begin
      v.instr.wdata = v.instr.mdata;
    end else if (v.instr.op.division == 1) begin
      v.instr.wdata = v.instr.ddata;
    end

    if (v.instr.op.mulc == 1) begin
      v.stall = ~v.instr.mready;
    end else if (v.instr.op.bitc == 1) begin
      v.stall = ~v.instr.bcready;
    end else if (v.instr.op.division == 1) begin
      v.stall = ~v.instr.dready;
    end

    if (v.instr.op.load == 1) begin
      v.instr.wdata = v.instr.ldata;
      v.stall = ~dmem_out.mem_ready;
    end else if (v.instr.op.store == 1) begin
      v.stall = ~dmem_out.mem_ready;
    end

    v.instr.op_b = v.instr.op;

    if ((v.stall | v.clear) == 1) begin
      v.instr.op = init_operation;
    end

    if (v.clear == 1) begin
      v.clear = 0;
      v.stall = 0;
    end

    if (v.instr.op.nop == 1) begin
      v.instr.op.valid = 0;
    end

    register_win.wren = v.instr.op.wren;
    register_win.waddr = v.instr.waddr;
    register_win.wdata = v.instr.wdata;

    forwarding_ein.wren = v.instr.op.wren;
    forwarding_ein.waddr = v.instr.waddr;
    forwarding_ein.wdata = v.instr.wdata;

    csr_ein.valid = v.instr.op.valid;
    csr_ein.cwren = v.instr.op.cwren;
    csr_ein.cwaddr = v.instr.caddr;
    csr_ein.cdata = v.instr.cwdata;

    csr_ein.mret = v.instr.op.mret;
    csr_ein.exception = v.instr.op.exception;
    csr_ein.epc = v.instr.pc;
    csr_ein.ecause = v.instr.ecause;
    csr_ein.etval = v.instr.etval;

    rin = v;

    y.instr = v.instr;
    y.stall = v.stall;
    y.clear = v.clear;

    q.instr = r.instr;
    q.stall = r.stall;
    q.clear = r.clear;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_execute_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
