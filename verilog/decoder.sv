import constants::*;
import wires::*;

module decoder
(
  input decoder_in_type decoder_in,
  output decoder_out_type decoder_out
);

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
  logic [6  : 0] funct7;
  logic [2  : 0] rm;

  logic [4  : 0] waddr;
  logic [11 : 0] caddr;

  logic [0  : 0] wren;
  logic [0  : 0] rden1;
  logic [0  : 0] rden2;

  logic [0  : 0] csr_wren;
  logic [0  : 0] csr_rden;

  logic [0  : 0] auipc;
  logic [0  : 0] lui;
  logic [0  : 0] jal;
  logic [0  : 0] jalr;
  logic [0  : 0] branch;
  logic [0  : 0] load;
  logic [0  : 0] store;
  logic [0  : 0] csr;
  logic [0  : 0] fence;
  logic [0  : 0] ecall;
  logic [0  : 0] ebreak;
  logic [0  : 0] mret;
  logic [0  : 0] wfi;
  logic [0  : 0] valid;

  alu_op_type alu_op;
  bcu_op_type bcu_op;
  lsu_op_type lsu_op;

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
    funct7 = instr[31:25];

    waddr = instr[11:7];
    caddr = instr[31:20];

    wren = 0;
    rden1 = 0;
    rden2 = 0;

    csr_wren = 0;
    csr_rden = 0;

    auipc = 0;
    lui = 0;
    lui = 0;
    jal = 0;
    jalr = 0;
    branch = 0;
    load = 0;
    store = 0;
    csr = 0;
    fence = 0;
    ecall = 0;
    ebreak = 0;
    mret = 0;
    wfi = 0;
    valid = 1;

    alu_op = init_alu_op;
    bcu_op = init_bcu_op;
    lsu_op = init_lsu_op;

    case (opcode)
      opcode_lui | opcode_auipc : begin
        imm = imm_u;
        wren = 1;
        auipc = opcode[5];
        lui = ~opcode[5];
      end
      opcode_jal | opcode_jalr : begin
        wren = 1;
        if (opcode[3] == 0) begin
          imm = imm_i;
          jalr = 1;
          rden1 = 1;
        end
        if (opcode[3] == 1) begin
          imm = imm_j;
          jal = 1;
        end
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
      opcode_load | opcode_store : begin
        rden1 = 1;
        if (opcode[5] == 0) begin
          imm = imm_i;
          wren = 1;
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
        if (opcode[5] == 1) begin
          imm = imm_s;
          rden2 = 1;
          store = 1;
          case (funct3)
            funct_sb : lsu_op.lsu_sb = 1;
            funct_sh : lsu_op.lsu_sh = 1;
            funct_sw : lsu_op.lsu_sw = 1;
            default : valid = 0;
          endcase;
        end
      end
      opcode_immediate | opcode_register : begin
        wren = 1;
        rden1 = 1;
        if (opcode[5] == 0) begin
          imm = imm_i;
          case (funct3)
            funct_add : alu_op.alu_add = 1;
            funct_sll : alu_op.alu_sll = 1;
            funct_srl : begin
              alu_op.alu_srl = ~funct7[5];
              alu_op.alu_sra = funct7[5];
            end
            funct_slt : alu_op.alu_slt = 1;
            funct_sltu : alu_op.alu_sltu = 1;
            funct_and : alu_op.alu_and = 1;
            funct_or : alu_op.alu_or = 1;
            funct_xor : alu_op.alu_xor = 1;
            default : valid = 0;
          endcase;
        end
        if (opcode[5] == 1) begin
          rden2 = 1;
          case (funct3)
            funct_add : begin
              alu_op.alu_add = ~funct7[5];
              alu_op.alu_sub = funct7[5];
            end
            funct_sll : alu_op.alu_sll = 1;
            funct_srl : begin
              alu_op.alu_srl = ~funct7[5];
              alu_op.alu_sra = funct7[5];
            end
            funct_slt : alu_op.alu_slt = 1;
            funct_sltu : alu_op.alu_sltu = 1;
            funct_and : alu_op.alu_and = 1;
            funct_or : alu_op.alu_or = 1;
            funct_xor : alu_op.alu_xor = 1;
            default : valid = 0;
          endcase;
        end
      end
      opcode_fence : begin
        if (funct3 == 1)
          fence = 1;
        else
          valid = 0;
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
        end else begin
          wren = 1;
          rden1 = 1;
          csr_wren = 1;
          csr_rden = 1;
          csr = 1;
        end
      end
      default : valid = 0;
    endcase;

    case (funct3)
      1 | 5 : csr_rden = csr_rden & |waddr;
      2 | 6 : csr_wren = csr_wren & |waddr;
      3 | 7 : csr_wren = csr_wren & |waddr;
    endcase

    if (waddr == 0) begin
      wren = 0;
    end

    if (instr == nop) begin
      alu_op.alu_add = 0;
    end

    decoder_out.imm = imm;
    decoder_out.wren = wren;
    decoder_out.rden1 = rden1;
    decoder_out.rden2 = rden2;
    decoder_out.csr_wren = csr_wren;
    decoder_out.csr_rden = csr_rden;
    decoder_out.auipc = auipc;
    decoder_out.lui = lui;
    decoder_out.jal = jal;
    decoder_out.jalr = jalr;
    decoder_out.branch = branch;
    decoder_out.load = load;
    decoder_out.store = store;
    decoder_out.csr = csr;
    decoder_out.alu_op = alu_op;
    decoder_out.bcu_op = bcu_op;
    decoder_out.lsu_op = lsu_op;
    decoder_out.fence = fence;
    decoder_out.ecall = ecall;
    decoder_out.ebreak = ebreak;
    decoder_out.mret = mret;
    decoder_out.wfi = wfi;
    decoder_out.valid = valid;

  end

endmodule
