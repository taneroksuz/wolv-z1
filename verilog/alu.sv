import wires::*;

module alu
(
  input alu_in_type alu_in,
  output alu_out_type alu_out
);

  logic [31 : 0] rs2;

  always_comb begin

    rs2 = alu_in.rs2;

    if (alu_in.alu_op.alu_sub == 1) begin
      rs2 = ~rs2;
    end

    if (alu_in.alu_op.alu_add == 1 && alu_in.alu_op.alu_sub == 1) begin
      alu_out.res = alu_in.rs1 + rs2;
    end else if (alu_in.alu_op.alu_sll == 1) begin
      alu_out.res = alu_in.rs1 << alu_in.shamt;
    end else if (alu_in.alu_op.alu_srl == 1) begin
      alu_out.res = alu_in.rs1 >> alu_in.shamt;
    end else if (alu_in.alu_op.alu_sra == 1) begin
      alu_out.res = alu_in.rs1 >>> alu_in.shamt;
    end else if (alu_in.alu_op.alu_slt == 1) begin
      alu_out.res = $signed(alu_in.rs1) < $signed(rs2);
    end else if (alu_in.alu_op.alu_sltu == 1) begin
      alu_out.res = alu_in.rs1 < rs2;
    end else if (alu_in.alu_op.alu_and == 1) begin
      alu_out.res = alu_in.rs1 & rs2;
    end else if (alu_in.alu_op.alu_or == 1) begin
      alu_out.res = alu_in.rs1 | rs2;
    end else if (alu_in.alu_op.alu_xor == 1) begin
      alu_out.res = alu_in.rs1 ^ rs2;
    end else begin
      alu_out.res = 0;
    end

  end

endmodule
