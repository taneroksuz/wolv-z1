import wires::*;

module execute_stage
(
  input logic rst,
  input logic clk,
  input alu_out_type alu_out,
  output alu_in_type alu_in,
  input lsu_out_type lsu_out,
  output lsu_in_type lsu_in,
  input csr_alu_out_type csr_alu_out,
  output csr_alu_in_type csr_alu_in,
  input muldiv_out_type muldiv_out,
  output muldiv_in_type muldiv_in,
  output register_in_type register_in,
  output forwarding_in_type forwarding_in,
  output csr_in_type csr_in,
  input mem_out_type dmem_out,
  input execute_in_type d,
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
    v.csr = d.d.csr;
    v.muldiv = d.d.muldiv;
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
    v.muldiv_op = d.d.muldiv_op;
    v.exception = d.d.exception;
    v.ecause = d.d.ecause;
    v.etval = d.d.etval;

    if (d.e.stall == 1) begin
      v = r;
    end

		v.clear = d.e.clear;

    v.stall = 0;

    alu_in.rdata1 = v.rdata1;
    alu_in.rdata2 = v.rdata2;
    alu_in.imm = v.imm;
    alu_in.sel = v.rden2;
    alu_in.alu_op = v.alu_op;

    v.wdata = alu_out.res;

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
    end

    csr_alu_in.cdata = v.cdata;
    csr_alu_in.rdata1 = v.rdata1;
    csr_alu_in.imm = v.imm;
    csr_alu_in.sel = v.rden1;
    csr_alu_in.csr_op = v.csr_op;

    v.cdata = csr_alu_out.cdata;

    muldiv_in.rdata1 = v.rdata1;
    muldiv_in.rdata2 = v.rdata2;
    muldiv_in.enable = v.muldiv & ~(d.e.clear | d.e.stall);
    muldiv_in.muldiv_op = v.muldiv_op;

    lsu_in.ldata = dmem_out.mem_rdata;
    lsu_in.byteenable = v.byteenable;
    lsu_in.lsu_op = v.lsu_op;

    v.ldata = lsu_out.res;

    if (v.muldiv == 1) begin
      if (muldiv_out.ready == 0) begin
        v.stall = 1;
      end else if (muldiv_out.ready == 1) begin
        v.wren = |v.waddr;
        v.wdata = muldiv_out.result;
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
      v.csr = 0;
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

    register_in.wren = v.wren;
    register_in.waddr = v.waddr;
    register_in.wdata = v.wdata;

    forwarding_in.execute_wren = v.wren;
    forwarding_in.execute_waddr = v.waddr;
    forwarding_in.execute_wdata = v.wdata;

    csr_in.valid = v.valid;
    csr_in.cwren = v.cwren;
    csr_in.cwaddr = v.caddr;
    csr_in.cdata = v.cdata;

    rin = v;

    q.stall = r.stall;
    q.clear = r.clear;

  end

  always_ff @(posedge clk) begin
    if (rst == 0) begin
      r <= init_execute_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
