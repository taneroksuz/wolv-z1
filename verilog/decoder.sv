import constants::*;
import wires::*;

module decoder
(
  input decoder_in_type decoder_in,
  output decoder_out_type decoder_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] instr;

  logic [31 : 0] imm_c;
  logic [31 : 0] imm_i;
  logic [31 : 0] imm_s;
  logic [31 : 0] imm_b;
  logic [31 : 0] imm_u;
  logic [31 : 0] imm_j;
  logic [31 : 0] imm;

  logic [6  : 0] opcode;
  logic [2  : 0] funct3;

  logic [4  : 0] waddr;
  logic [4  : 0] raddr1;
  logic [11 : 0] caddr;

  logic [0  : 0] wren;
  logic [0  : 0] rden1;
  logic [0  : 0] rden2;

  logic [0  : 0] cwren;
  logic [0  : 0] crden;

  logic [0  : 0] auipc;
  logic [0  : 0] lui;
  logic [0  : 0] jal;
  logic [0  : 0] jalr;
  logic [0  : 0] branch;
  logic [0  : 0] load;
  logic [0  : 0] store;
  logic [0  : 0] csr;
  logic [0  : 0] muldiv;
  logic [0  : 0] fence;
  logic [0  : 0] ecall;
  logic [0  : 0] ebreak;
  logic [0  : 0] mret;
  logic [0  : 0] wfi;
  logic [0  : 0] valid;

  alu_op_type alu_op;
  bcu_op_type bcu_op;
  lsu_op_type lsu_op;
  csr_op_type csr_op;

  muldiv_op_type muldiv_op;

  logic [0  : 0] nonzero_waddr;
  logic [0  : 0] nonzero_raddr1;

  logic [0  : 0] nonzero_imm_c;
  logic [0  : 0] nonzero_imm_i;
  logic [0  : 0] nonzero_imm_s;
  logic [0  : 0] nonzero_imm_b;
  logic [0  : 0] nonzero_imm_u;
  logic [0  : 0] nonzero_imm_j;

  always_comb begin

    instr = decoder_in.instr;

    imm_c = {{27{instr[19]}},instr[19:15]};
    imm_i = {{20{instr[31]}},instr[31:20]};
    imm_s = {{20{instr[31]}},instr[31:25],instr[11:7]};
    imm_b = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
    imm_u = {instr[31:12],12'h0};
    imm_j = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0};

    imm = 0;

    opcode = instr[6:0];
    funct3 = instr[14:12];

    waddr = instr[11:7];
    raddr1 = instr[19:15];
    caddr = instr[31:20];

    wren = 0;
    rden1 = 0;
    rden2 = 0;

    cwren = 0;
    crden = 0;

    auipc = 0;
    lui = 0;
    jal = 0;
    jalr = 0;
    branch = 0;
    load = 0;
    store = 0;
    csr = 0;
    muldiv = 0;
    fence = 0;
    ecall = 0;
    ebreak = 0;
    mret = 0;
    wfi = 0;
    valid = 1;

    alu_op = init_alu_op;
    bcu_op = init_bcu_op;
    lsu_op = init_lsu_op;
    csr_op = init_csr_op;

    muldiv_op = init_muldiv_op;

    nonzero_waddr = |waddr;
    nonzero_raddr1 = |raddr1;

    nonzero_imm_c = |imm_c;
    nonzero_imm_i = |imm_i;
    nonzero_imm_s = |imm_s;
    nonzero_imm_b = |imm_b;
    nonzero_imm_u = |imm_u;
    nonzero_imm_j = |imm_j;

    case (opcode)
      opcode_lui : begin
        imm = imm_u;
        wren = nonzero_waddr;
        lui = 1;
      end
      opcode_auipc : begin
        imm = imm_u;
        wren = nonzero_waddr;
        auipc = 1;
      end
      opcode_jal : begin
        wren = nonzero_waddr;
        imm = imm_j;
        jal = 1;
      end
      opcode_jalr : begin
        imm = imm_i;
        wren = nonzero_waddr;
        rden1 = 1;
        jalr = 1;
      end
      opcode_branch : begin
        imm = imm_b;
        rden1 = 1;
        rden2 = 1;
        branch = 1;
        case (funct3)
          funct_beq : bcu_op.bcu_beq = 1;
          funct_bne : bcu_op.bcu_bne = 1;
          funct_blt : bcu_op.bcu_blt = 1;
          funct_bge : bcu_op.bcu_bge = 1;
          funct_bltu : bcu_op.bcu_bltu = 1;
          funct_bgeu : bcu_op.bcu_bgeu = 1;
          default : valid = 0;
        endcase
      end
      opcode_load : begin
        imm = imm_i;
        wren = nonzero_waddr;
        rden1 = 1;
        load = 1;
        case (funct3)
          funct_lb : lsu_op.lsu_lb = 1;
          funct_lh : lsu_op.lsu_lh = 1;
          funct_lw : lsu_op.lsu_lw = 1;
          funct_lbu : lsu_op.lsu_lbu = 1;
          funct_lhu : lsu_op.lsu_lhu = 1;
          default : valid = 0;
        endcase;
      end
      opcode_store : begin
        imm = imm_s;
        rden1 = 1;
        rden2 = 1;
        store = 1;
        case (funct3)
          funct_sb : lsu_op.lsu_sb = 1;
          funct_sh : lsu_op.lsu_sh = 1;
          funct_sw : lsu_op.lsu_sw = 1;
          default : valid = 0;
        endcase;
      end
      opcode_immediate : begin
        wren = nonzero_waddr;
        rden1 = 1;
        imm = imm_i;
        case (funct3)
          funct_add : alu_op.alu_add = 1;
          funct_sll : begin
            alu_op.alu_sll = 1;
            valid = ~instr[25];
          end
          funct_srl : begin
            alu_op.alu_srl = ~instr[30];
            alu_op.alu_sra = instr[30];
            valid = ~instr[25];
          end
          funct_slt : alu_op.alu_slt = 1;
          funct_sltu : alu_op.alu_sltu = 1;
          funct_and : alu_op.alu_and = 1;
          funct_or : alu_op.alu_or = 1;
          funct_xor : alu_op.alu_xor = 1;
          default : valid = 0;
        endcase;
      end
      opcode_register : begin
        wren = nonzero_waddr;
        rden1 = 1;
        rden2 = 1;
        if (instr[25] == 0) begin
          case (funct3)
            funct_add : begin
              alu_op.alu_add = ~instr[30];
              alu_op.alu_sub = instr[30];
            end
            funct_sll : alu_op.alu_sll = 1;
            funct_srl : begin
              alu_op.alu_srl = ~instr[30];
              alu_op.alu_sra = instr[30];
            end
            funct_slt : alu_op.alu_slt = 1;
            funct_sltu : alu_op.alu_sltu = 1;
            funct_and : alu_op.alu_and = 1;
            funct_or : alu_op.alu_or = 1;
            funct_xor : alu_op.alu_xor = 1;
            default : valid = 0;
          endcase;
        end else if (instr[25] == 1) begin
          muldiv = 1;
          case (funct3)
            funct_mul : muldiv_op.muldiv_mul = 1;
            funct_mulh : muldiv_op.muldiv_mulh = 1;
            funct_mulhsu : muldiv_op.muldiv_mulhsu = 1;
            funct_mulhu : muldiv_op.muldiv_mulhu = 1;
            funct_div : muldiv_op.muldiv_div = 1;
            funct_divu : muldiv_op.muldiv_divu = 1;
            funct_rem : muldiv_op.muldiv_rem = 1;
            funct_remu : muldiv_op.muldiv_remu = 1;
            default : valid = 0;
          endcase;
        end
      end
      opcode_fence : begin
        if (funct3 == 1) begin
          fence = 1;
        end
      end
      opcode_system : begin
        imm = imm_c;
        if (funct3 == 0) begin
          case (caddr)
            csr_ecall : ecall = 1;
            csr_ebreak : ebreak = 1;
            csr_mret : mret = 1;
            csr_wfi : wfi = 1;
            default : valid = 0;
          endcase
        end else if (funct3 == 1) begin
          wren = nonzero_waddr;
          rden1 = 1;
          cwren = 1;
          crden = nonzero_waddr;
          csr_op.csrrw = 1;
          csr = 1;
        end else if (funct3 == 2) begin
          wren = nonzero_waddr;
          rden1 = 1;
          cwren = nonzero_waddr;
          crden = 1;
          csr_op.csrrs = 1;
          csr = 1;
        end else if (funct3 == 3) begin
          wren = nonzero_waddr;
          rden1 = 1;
          cwren = nonzero_waddr;
          crden = 1;
          csr_op.csrrc = 1;
          csr = 1;
        end else if (funct3 == 5) begin
          wren = nonzero_waddr;
          cwren = 1;
          crden = nonzero_waddr;
          csr_op.csrrwi = 1;
          csr = 1;
        end else if (funct3 == 6) begin
          wren = nonzero_waddr;
          cwren = nonzero_imm_c;
          crden = 1;
          csr_op.csrrsi = 1;
          csr = 1;
        end else if (funct3 == 7) begin
          wren = nonzero_waddr;
          cwren = nonzero_imm_c;
          crden = 1;
          csr_op.csrrci = 1;
          csr = 1;
        end
      end
      default : valid = 0;
    endcase;

    if (instr == nop) begin
      alu_op.alu_add = 0;
    end

    decoder_out.imm = imm;
    decoder_out.wren = wren;
    decoder_out.rden1 = rden1;
    decoder_out.rden2 = rden2;
    decoder_out.cwren = cwren;
    decoder_out.crden = crden;
    decoder_out.auipc = auipc;
    decoder_out.lui = lui;
    decoder_out.jal = jal;
    decoder_out.jalr = jalr;
    decoder_out.branch = branch;
    decoder_out.load = load;
    decoder_out.store = store;
    decoder_out.csr = csr;
    decoder_out.muldiv = muldiv;
    decoder_out.alu_op = alu_op;
    decoder_out.bcu_op = bcu_op;
    decoder_out.lsu_op = lsu_op;
    decoder_out.csr_op = csr_op;
    decoder_out.muldiv_op = muldiv_op;
    decoder_out.fence = fence;
    decoder_out.ecall = ecall;
    decoder_out.ebreak = ebreak;
    decoder_out.mret = mret;
    decoder_out.wfi = wfi;
    decoder_out.valid = valid;

  end

endmodule
