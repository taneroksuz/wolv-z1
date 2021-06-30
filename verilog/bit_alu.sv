import wires::*;
import functions::*;

module bit_alu
(
  input bit_alu_in_type bit_alu_in,
  output bit_alu_out_type bit_alu_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] rs1;
  logic [31 : 0] rs2;
  logic [31 : 0] res;

  logic [1 : 0] index;
  logic [1 : 0] op;

  zba_op_type bit_zba;
  zbb_op_type bit_zbb;
  zbs_op_type bit_zbs;

  always_comb begin

    rs1 = bit_alu_in.rs1;
    rs2 = multiplexer(bit_alu_in.imm,bit_alu_in.rs2,bit_alu_in.sel);
    res = 0;

    index = 0;
    op = 0;

		bit_zba = bit_alu_in.bit_op.bit_zba;
		bit_zbb = bit_alu_in.bit_op.bit_zbb;
		bit_zbs = bit_alu_in.bit_op.bit_zbs;

		if (bit_zba.bit_sh1add == 1) begin
			index = 1;
		end else if (bit_zba.bit_sh2add == 1) begin
			index = 2;
		end else if (bit_zba.bit_sh3add == 1) begin
			index = 3;
		end

		if (bit_zbb.bit_max == 1) begin
			op = 0;
		end else if (bit_zbb.bit_maxu == 1) begin
			op = 1;
		end else if (bit_zbb.bit_min == 1) begin
			op = 2;
		end else if (bit_zbb.bit_minu == 1) begin
			op = 3;
		end

		if ((bit_zba.bit_sh1add | bit_zba.bit_sh2add | bit_zba.bit_sh3add) == 1) begin
			res = bit_shadd(rs1,rs2,index);
		end else if (bit_zbb.bit_andn == 1) begin
			res = bit_andn(rs1,rs2);
		end else if (bit_zbb.bit_orn == 1) begin
			res = bit_orn(rs1,rs2);
		end else if (bit_zbb.bit_xnor == 1) begin
			res = bit_xnor(rs1,rs2);
		end else if (bit_zbb.bit_clz == 1) begin
			res = bit_clz(rs1);
		end else if (bit_zbb.bit_cpop == 1) begin
			res = bit_cpop(rs1);
		end else if (bit_zbb.bit_ctz == 1) begin
			res = bit_ctz(rs1);
		end else if ((bit_zbb.bit_max | bit_zbb.bit_maxu | bit_zbb.bit_min | bit_zbb.bit_minu) == 1) begin
			res = bit_minmax(rs1,rs2,op);
		end else if (bit_zbb.bit_orcb == 1) begin
			res = bit_orcb(rs1);
		end else if (bit_zbb.bit_rev8 == 1) begin
			res = bit_rev8(rs1);
		end else if (bit_zbb.bit_rol == 1) begin
			res = bit_rol(rs1,rs2);
		end else if (bit_zbb.bit_ror == 1) begin
			res = bit_ror(rs1,rs2);
		end else if (bit_zbb.bit_sextb == 1) begin
			res = bit_sextb(rs1);
		end else if (bit_zbb.bit_sexth == 1) begin
			res = bit_sexth(rs1);
		end else if (bit_zbb.bit_zexth == 1) begin
			res = bit_zexth(rs1);
		end else if (bit_zbs.bit_bclr == 1) begin
			res = bit_bclr(rs1,rs2);
		end else if (bit_zbs.bit_bext == 1) begin
			res = bit_bext(rs1,rs2);
		end else if (bit_zbs.bit_binv == 1) begin
			res = bit_binv(rs1,rs2);
		end else if (bit_zbs.bit_bset == 1) begin
			res = bit_bset(rs1,rs2);
		end

    bit_alu_out.res = res;

  end

endmodule
