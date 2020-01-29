timeunit 1ns;
timeprecision 1ps;

import constants::*;
import wires::*;

module csr
(
  input logic rst,
  input logic clk,
  input csr_in_type csr_in,
  output csr_out_type csr_out
);

  csr_machine_reg_type csr_machine_reg;

  logic [0:0] exception;
  logic [0:0] mret;

  always_comb begin
    if (csr_in.crden == 1) begin
      case (csr_in.craddr)
        csr_mstatus : csr_out.cdata = {csr_machine_reg.mstatus[31],
                                       8'h0,
                                       csr_machine_reg.mstatus[22:11],
                                       2'h0,
                                       csr_machine_reg.mstatus[8:7],
                                       1'h0,
                                       csr_machine_reg.mstatus[5:3],
                                       1'h0,
                                       csr_machine_reg.mstatus[1:0]};
        csr_misa : csr_out.cdata = {csr_machine_reg.misa[31:30],
                                    4'h0,
                                    csr_machine_reg.misa[25:0]};
        csr_medeleg : csr_out.cdata = csr_machine_reg.medeleg;
        csr_mideleg : csr_out.cdata = csr_machine_reg.mideleg;
        csr_mie : csr_out.cdata = {20'h0,
                                   csr_machine_reg.mie[11],
                                   1'h0,
                                   csr_machine_reg.mie[9:7],
                                   1'h0,
                                   csr_machine_reg.mie[5:3],
                                   1'h0,
                                   csr_machine_reg.mie[1:0]};
        csr_mtvec : csr_out.cdata = csr_machine_reg.mtvec;
        csr_mcounteren : csr_out.cdata = csr_machine_reg.mcounteren;
        csr_mscratch : csr_out.cdata = csr_machine_reg.mscratch;
        csr_mepc : csr_out.cdata = csr_machine_reg.mepc;
        csr_mcause : csr_out.cdata = csr_machine_reg.mcause;
        csr_mtval : csr_out.cdata = csr_machine_reg.mtval;
        csr_mip : csr_out.cdata = {20'h0,
                                   csr_machine_reg.mip[11],
                                   1'h0,
                                   csr_machine_reg.mip[9:7],
                                   1'h0,
                                   csr_machine_reg.mip[5:3],
                                   1'h0,
                                   csr_machine_reg.mip[1:0]};
        csr_mcycle : csr_out.cdata = csr_machine_reg.mcycle[31:0];
        csr_mcycleh : csr_out.cdata = csr_machine_reg.mcycle[63:32];
        csr_minstret : csr_out.cdata = csr_machine_reg.minstret[31:0];
        csr_minstreth : csr_out.cdata = csr_machine_reg.minstret[63:32];
        default : csr_out.cdata = 0;
      endcase
    end else begin
      csr_out.cdata = 0;
    end

    csr_out.exception = exception;
    csr_out.mret = mret;
    csr_out.mepc = csr_machine_reg.mepc;
    if (csr_machine_reg.mtvec[1:0] == 1) begin
      csr_out.mtvec = {(csr_machine_reg.mtvec[31:2] + {26'b0,csr_machine_reg.mcause[3:0]}),2'b0};
    end else begin
      csr_out.mtvec = {csr_machine_reg.mtvec[31:2],2'b0};
    end

  end

  always_ff @(posedge clk) begin

    if (rst == 0) begin
      csr_machine_reg <= init_csr_machine_reg;
    end else begin
      if (csr_in.cwren == 1) begin
        case (csr_in.cwaddr)
          csr_mstatus : begin
            csr_machine_reg.mstatus[31] <= csr_in.cdata[31];
            csr_machine_reg.mstatus[22:11] <= csr_in.cdata[22:11];
            csr_machine_reg.mstatus[8:7] <= csr_in.cdata[8:7];
            csr_machine_reg.mstatus[5:3] <= csr_in.cdata[5:3];
            csr_machine_reg.mstatus[1:0] <= csr_in.cdata[1:0];
          end
          csr_misa : begin
            csr_machine_reg.misa[31:30] <= csr_in.cdata[31:30];
            csr_machine_reg.misa[25:0] <= csr_in.cdata[25:0];
          end
          csr_medeleg : csr_machine_reg.medeleg <= csr_in.cdata;
          csr_mideleg : csr_machine_reg.mideleg <= csr_in.cdata;
          csr_mie : begin
            csr_machine_reg.mie[11] <= csr_in.cdata[11];
            csr_machine_reg.mie[9:7] <= csr_in.cdata[9:7];
            csr_machine_reg.mie[5:3] <= csr_in.cdata[5:3];
            csr_machine_reg.mie[1:0] <= csr_in.cdata[1:0];
          end
          csr_mtvec : csr_machine_reg.mtvec <= csr_in.cdata;
          csr_mcounteren : csr_machine_reg.mcounteren <= csr_in.cdata;
          csr_mscratch : csr_machine_reg.mscratch <= csr_in.cdata;
          csr_mepc : csr_machine_reg.mepc <= csr_in.cdata;
          csr_mcause : csr_machine_reg.mcause <= csr_in.cdata;
          csr_mtval : csr_machine_reg.mtval <= csr_in.cdata;
          csr_mip : begin
            csr_machine_reg.mip[11] <= csr_in.cdata[11];
            csr_machine_reg.mip[9:7] <= csr_in.cdata[9:7];
            csr_machine_reg.mip[5:3] <= csr_in.cdata[5:3];
            csr_machine_reg.mip[1:0] <= csr_in.cdata[1:0];
          end
          csr_mcycle : csr_machine_reg.mcycle[31:0] <= csr_in.cdata;
          csr_mcycleh : csr_machine_reg.mcycle[63:32] <= csr_in.cdata;
          csr_minstret : csr_machine_reg.minstret[31:0] <= csr_in.cdata;
          csr_minstreth : csr_machine_reg.minstret[63:32] <= csr_in.cdata;
          default :;
        endcase
      end

      if (csr_in.valid == 1) begin
        csr_machine_reg.minstret <= csr_machine_reg.minstret + 1;
      end

      csr_machine_reg.mcycle <= csr_machine_reg.mcycle + 1;

      if (csr_in.exception == 1) begin
        csr_machine_reg.mstatus[7] <= csr_machine_reg.mstatus[3];
        csr_machine_reg.mstatus[3] <= 0;
        csr_machine_reg.mepc <= csr_in.epc;
        csr_machine_reg.mtval <= csr_in.etval;
        csr_machine_reg.mcause <= {28'b0,csr_in.ecause};
        exception <= 1;
      end else begin
        exception <= 0;
      end

      if (csr_in.mret == 1) begin
        csr_machine_reg.mstatus[3] <= csr_machine_reg.mstatus[7];
        csr_machine_reg.mstatus[7] <= 0;
        mret <= 1;
      end else begin
        mret <= 0;
      end

    end

  end

endmodule
