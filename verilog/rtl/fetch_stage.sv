import constants::*;
import functions::*;
import wires::*;

module fetch_stage
(
  input logic reset,
  input logic clock,
  input buffer_out_type buffer_out,
  output buffer_in_type buffer_in,
  input csr_out_type csr_out,
  input mem_out_type imem_out,
  output mem_in_type imem_in,
  input fetch_in_type a,
  input fetch_in_type d,
  output fetch_out_type y,
  output fetch_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam [1:0] idle = 0;
  localparam [1:0] busy = 1;
  localparam [1:0] ctrl = 2;
  localparam [1:0] inv = 3;

  fetch_reg_type r,rin;
  fetch_reg_type v;

  always_comb begin

    v = r;

    v.valid = 0;
    v.stall = buffer_out.stall;

    v.fence = 0;
    v.spec = 0;
    
    v.rdata = imem_out.mem_rdata;
    v.ready = imem_out.mem_ready;

    v.pc = buffer_out.pc;
    v.instr = buffer_out.instr;
    v.done = buffer_out.done;

    case(v.state)
      idle : begin
        v.stall = 1;
      end
      busy : begin
        if (v.ready == 0) begin
          v.stall = 1;
        end
      end
      ctrl : begin
        v.stall = 1;
      end
      inv : begin
        v.stall = 1;
      end
      default : begin
      end
    endcase

    if (csr_out.trap == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.addr = csr_out.mtvec;
    end else if (csr_out.mret == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.addr = csr_out.mepc;
    end else if (d.d.instr.op.jump == 1) begin
      v.fence = 0;
      v.spec = 1;
      v.addr = d.d.instr.address;
    end else if (d.d.instr.op.fence == 1) begin
      v.fence = 1;
      v.spec = 1;
      v.addr = d.d.instr.npc;
    end else if (v.stall == 0) begin
      v.fence = 0;
      v.spec = 0;
      v.addr = v.addr + 4;
    end

    case(v.state)
      idle : begin
        if (d.e.clear == 0) begin
          v.state = busy;
          v.valid = 1;
        end
      end
      busy : begin
        if (v.ready == 1) begin
          v.state = busy;
          v.valid = 1;
        end else if (v.spec == 1) begin
          v.state = ctrl;
          v.valid = 0;
        end else if (v.fence == 1) begin
          v.state = inv;
          v.valid = 0;
        end else begin
          v.state = busy;
          v.valid = 0;
        end
      end
      ctrl : begin
        if (v.ready == 1) begin
          v.state = busy;
          v.valid = 1;
        end else begin
          v.state = ctrl;
          v.valid = 0;
        end
        v.ready = 0;
      end
      inv : begin
        if (v.ready == 1) begin
          v.state = busy;
          v.valid = 1;
        end else begin
          v.state = inv;
          v.valid = 0;
        end
        v.ready = 0;
      end
      default : begin
      end
    endcase

    buffer_in.pc = {r.addr[31:2],2'b00};
    buffer_in.rdata = v.rdata;
    buffer_in.ready = v.ready;
    buffer_in.align = v.addr[1];
    buffer_in.clear = v.spec;
    buffer_in.stall = a.d.stall | a.e.stall;

    imem_in.mem_valid = v.valid;
    imem_in.mem_fence = v.fence;
    imem_in.mem_spec = v.spec;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.addr;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    rin = v;

    y.pc = v.pc;
    y.instr = v.instr;
    y.done = v.done;

    q.pc = r.pc;
    q.instr = r.instr;
    q.done = r.done;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
