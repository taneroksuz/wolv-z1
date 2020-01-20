import wires::*;

module bcu
(
  input bcu_in_type bcu_in,
  output bcu_out_type bcu_out
);

  always_comb begin

    if (bcu_in.op.bcu_beq == 1) begin
      bcu_reg.branch = bcu_in.rs1 == bcu_in.rs2;
    end else if (bcu_in.op.bcu_bne == 1) begin
      bcu_reg.branch = bcu_in.rs1 != bcu_in.rs2;
    end else if (bcu_in.op.bcu_blt == 1) begin
      bcu_reg.branch = $signed(bcu_in.rs1) < $signed(bcu_in.rs2);
    end else if (bcu_in.op.bcu_bge == 1) begin
      bcu_reg.branch = $signed(bcu_in.rs1) >= $signed(bcu_in.rs2);
    end else if (bcu_in.op.bcu_bltu == 1) begin
      bcu_reg.branch = bcu_in.rs1 < bcu_in.rs2;
    end else if (bcu_in.op.bcu_bgeu == 1) begin
      bcu_reg.branch = bcu_in.rs1 >= bcu_in.rs2;
    end else begin
      bcu_out.branch = 1'b0;
    end

  end

endmodule
