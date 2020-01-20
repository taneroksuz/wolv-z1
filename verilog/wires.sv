package wires;

  typedef struct packed{
    logic [0 : 0] alu_add;
    logic [0 : 0] alu_sub;
    logic [0 : 0] alu_sll;
    logic [0 : 0] alu_srl;
    logic [0 : 0] alu_sra;
    logic [0 : 0] alu_slt;
    logic [0 : 0] alu_sltu;
    logic [0 : 0] alu_and;
    logic [0 : 0] alu_or;
    logic [0 : 0] alu_xor;
  } alu_op_type;

  alu_op_type init_alu_op = '{
    alu_add : 0,
    alu_sub : 0,
    alu_sll : 0,
    alu_srl : 0,
    alu_sra : 0,
    alu_slt : 0,
    alu_sltu : 0,
    alu_and : 0,
    alu_or : 0,
    alu_xor : 0
  };

  typedef struct packed{
    logic [0 : 0] lsu_lb;
    logic [0 : 0] lsu_lbu;
    logic [0 : 0] lsu_lh;
    logic [0 : 0] lsu_lhu;
    logic [0 : 0] lsu_lw;
    logic [0 : 0] lsu_sb;
    logic [0 : 0] lsu_sh;
    logic [0 : 0] lsu_sw;
  } lsu_op_type;

  lsu_op_type init_lsu_op = '{
    lsu_lb : 0,
    lsu_lbu : 0,
    lsu_lh : 0,
    lsu_lhu : 0,
    lsu_lw : 0,
    lsu_sb : 0,
    lsu_sh : 0,
    lsu_sw : 0
  };

  typedef struct packed{
    logic [0 : 0] bcu_beq;
    logic [0 : 0] bcu_bne;
    logic [0 : 0] bcu_blt;
    logic [0 : 0] bcu_bge;
    logic [0 : 0] bcu_bltu;
    logic [0 : 0] bcu_begu;
  } bcu_op_type;

  bcu_op_type init_bcu_op = '{
    bcu_beq : 0,
    bcu_bne : 0,
    bcu_blt : 0,
    bcu_bge : 0,
    bcu_bltu : 0,
    bcu_begu : 0
  };

  typedef struct packed{
    logic [31 : 0] rs1;
    logic [31 : 0] rs2;
    logic [31 : 0] imm;
    logic [4  : 0] shamt;
    logic [0  : 0] sel;
    alu_op_type alu_op;
  } alu_in_type;

  typedef struct packed{
    logic [31 : 0] res;
  } alu_out_type;

  typedef struct packed{
    logic [31 : 0] rs1;
    logic [31 : 0] rs2;
    bcu_op_type op;
  } bcu_in_type;

  typedef struct packed{
    logic [0 : 0] branch;
  } bcu_out_type;

  typedef struct packed{
    logic [31 : 0] rs1;
    logic [31 : 0] imm;
    logic [31 : 0] pc;
    logic [0  : 0] auipc;
    logic [0  : 0] jal;
    logic [0  : 0] jalr;
    logic [0  : 0] branch;
    logic [0  : 0] load;
    logic [0  : 0] store;
    lsu_op_type lsu_op;
  } agu_in_type;

  typedef struct packed{
    logic [31 : 0] address;
    logic [3  : 0] byteenable;
    logic [0  : 0] exception;
    logic [3  : 0] ecause;
    logic [31 : 0] etval;
  } agu_out_type;

endpackage
