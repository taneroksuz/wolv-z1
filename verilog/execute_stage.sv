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

    v.pc = d.d.pc;
    v.npc = d.d.npc;
    v.imm = d.d.imm;
    v.wren = d.d.wren;
    v.rden1 = d.d.rden1;
    v.rden2 = d.d.rden2;
    v.cwren = d.d.cwren;
    v.crden = d.d.crden;
    v.waddr = d.d.waddr;
    v.raddr1 = d.d.raddr1;
    v.raddr2 = d.d.raddr2;
    v.caddr = d.d.caddr;
    v.auipc = d.d.auipc;
    v.lui = d.d.lui;
    v.jal = d.d.jal;
    v.jalr = d.d.jalr;
    v.branch = d.d.branch;
    v.load = d.d.load;
    v.store = d.d.store;
    v.nop = d.d.nop;
    v.csrreg = d.d.csrreg;
    v.division = d.d.division;
    v.mult = d.d.mult;
    v.mulc = d.d.mulc;
    v.bitm = d.d.bitm;
    v.bitc = d.d.bitc;
    v.fence = d.d.fence;
    v.ecall = d.d.ecall;
    v.ebreak = d.d.ebreak;
    v.mret = d.d.mret;
    v.wfi = d.d.wfi;
    v.valid = d.d.valid;
    v.rdata1 = d.d.rdata1;
    v.rdata2 = d.d.rdata2;
    v.cdata = d.d.cdata;
    v.address = d.d.address;
    v.byteenable = d.d.byteenable;
    v.alu_op = d.d.alu_op;
    v.bcu_op = d.d.bcu_op;
    v.lsu_op = d.d.lsu_op;
    v.csr_op = d.d.csr_op;
    v.div_op = d.d.div_op;
    v.mul_op = d.d.mul_op;
    v.bit_op = d.d.bit_op;
    v.exception = d.d.exception;
    v.ecause = d.d.ecause;
    v.etval = d.d.etval;

    if (d.e.stall == 1) begin
      v = r;
    end

    v.clear = csr_out.trap | csr_out.mret | d.e.clear;

    v.stall = 0;

    alu_in.rdata1 = v.rdata1;
    alu_in.rdata2 = v.rdata2;
    alu_in.imm = v.imm;
    alu_in.sel = v.rden2;
    alu_in.alu_op = v.alu_op;

    v.wdata = alu_out.result;

    bit_alu_in.rdata1 = v.rdata1;
    bit_alu_in.rdata2 = v.rdata2;
    bit_alu_in.imm = v.imm;
    bit_alu_in.sel = v.rden2;
    bit_alu_in.bit_op = v.bit_op;

    v.bdata = bit_alu_out.result;

    mul_in.rdata1 = v.rdata1;
    mul_in.rdata2 = v.rdata2;
    mul_in.enable = v.mult & ~(d.e.clear | d.e.stall);
    mul_in.op = v.mul_op;

    v.mdata = mul_out.result;

    if (v.auipc == 1) begin
      v.wdata = v.address;
    end else if (v.lui == 1) begin
      v.wdata = v.imm;
    end else if (v.jal == 1) begin
      v.wdata = v.npc;
    end else if (v.jalr == 1) begin
      v.wdata = v.npc;
    end else if (v.crden == 1) begin
      v.wdata = v.cdata;
    end else if (v.mult == 1) begin
      v.wdata = v.mdata;
    end else if (v.bitm == 1) begin
      v.wdata = v.bdata;
    end

    csr_alu_in.cdata = v.cdata;
    csr_alu_in.rdata1 = v.rdata1;
    csr_alu_in.imm = v.imm;
    csr_alu_in.sel = v.rden1;
    csr_alu_in.csr_op = v.csr_op;

    v.cdata = csr_alu_out.cdata;

    div_in.rdata1 = v.rdata1;
    div_in.rdata2 = v.rdata2;
    div_in.enable = v.division & ~(d.e.clear | d.e.stall);
    div_in.op = v.div_op;

    bit_clmul_in.rdata1 = v.rdata1;
    bit_clmul_in.rdata2 = v.rdata2;
    bit_clmul_in.enable = v.bitm & ~(d.e.clear | d.e.stall);
    bit_clmul_in.op = v.bit_op.bit_zbc;

    lsu_in.ldata = dmem_out.mem_rdata;
    lsu_in.byteenable = v.byteenable;
    lsu_in.lsu_op = v.lsu_op;

    v.ldata = lsu_out.result;

    if (v.division == 1) begin
      if (div_out.ready == 0) begin
        v.stall = 1;
      end else if (div_out.ready == 1) begin
        v.wren = |v.waddr;
        v.wdata = div_out.result;
      end
    end else if (v.mult == 1 && v.mulc == 1) begin
      if (mul_out.ready == 0) begin
        v.stall = 1;
      end else if (mul_out.ready == 1) begin
        v.wren = |v.waddr;
        v.wdata = mul_out.result;
      end
    end else if (v.bitm == 1 && v.bitc == 1) begin
      if (bit_clmul_out.ready == 0) begin
        v.stall = 1;
      end else if (bit_clmul_out.ready == 1) begin
        v.wren = |v.waddr;
        v.wdata = bit_clmul_out.result;
      end
    end

    if (v.load == 1 | v.store == 1) begin
      if (dmem_out.mem_ready == 0) begin
        v.stall = 1;
      end else if (dmem_out.mem_ready == 1) begin
        v.wren = v.load & |v.waddr;
        v.wdata = v.ldata;
      end
    end

    if ((v.stall | v.clear) == 1) begin
      v.wren = 0;
      v.cwren = 0;
      v.auipc = 0;
      v.lui = 0;
      v.jal = 0;
      v.jalr = 0;
      v.branch = 0;
      v.nop = 0;
      v.csrreg = 0;
      v.fence = 0;
      v.ecall = 0;
      v.ebreak = 0;
      v.mret = 0;
      v.wfi = 0;
      v.exception = 0;
      v.clear = 0;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    if (v.nop == 1) begin
      v.valid = 0;
    end

    register_win.wren = v.wren & |(v.waddr);
    register_win.waddr = v.waddr;
    register_win.wdata = v.wdata;

    forwarding_ein.wren = v.wren;
    forwarding_ein.waddr = v.waddr;
    forwarding_ein.wdata = v.wdata;

    csr_ein.valid = v.valid;
    csr_ein.cwren = v.cwren;
    csr_ein.cwaddr = v.caddr;
    csr_ein.cdata = v.cdata;

    csr_ein.mret = v.mret;
    csr_ein.exception = v.exception;
    csr_ein.epc = v.pc;
    csr_ein.ecause = v.ecause;
    csr_ein.etval = v.etval;

    rin = v;

    y.cwren = v.cwren;
    y.division = v.division;
    y.mult = v.mult;
    y.mulc = v.mulc;
    y.bitm = v.bitm;
    y.bitc = v.bitc;
    y.stall = v.stall;
    y.clear = v.clear;

    q.cwren = r.cwren;
    q.division = r.division;
    q.mult = r.mult;
    q.mulc = r.mulc;
    q.bitm = r.bitm;
    q.bitc = r.bitc;
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
