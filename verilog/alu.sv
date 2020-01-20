import wires::*;
import functions::*;

module alu
(
  input alu_in_type alu_in,
  output alu_out_type alu_out
);

  logic [31 : 0] op1;
  logic [31 : 0] op2;

  always_comb begin

    op1 = alu_in.rs1;
    op2 = multiplexer(alu_in.rs2,alu_in.imm,alu_in.sel);

    if (alu_in.op.alu_sub == 1) begin
      op2 = ~op2;
    end

    if (alu_in.op.alu_add == 1 && alu_in.op.alu_sub == 1) begin
      alu_out.res = op1 + op2;
    end else if (alu_in.op.alu_sll == 1) begin
      alu_out.res = op1 << alu_in.shamt;
    end else if (alu_in.op.alu_srl == 1) begin
      alu_out.res = op1 >> alu_in.shamt;
    end else if (alu_in.op.alu_sra == 1) begin
      alu_out.res = op1 >>> alu_in.shamt;
    end else if (alu_in.op.alu_slt == 1) begin
      alu_out.res = $signed(op1) < $signed(op2);
    end else if (alu_in.op.alu_sltu == 1) begin
      alu_out.res = op1 < op2;
    end else if (alu_in.op.alu_and == 1) begin
      alu_out.res = op1 & op2;
    end else if (alu_in.op.alu_or == 1) begin
      alu_out.res = op1 | op2;
    end else if (alu_in.op.alu_xor == 1) begin
      alu_out.res = op1 ^ op2;
    end else begin
      alu_out.res = 0;
    end

  end

endmodule
