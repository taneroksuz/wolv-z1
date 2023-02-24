import configure::*;
import wires::*;

module cpu
(
  input logic reset,
  input logic clock,
  output logic [0  : 0] memory_valid,
  output logic [0  : 0] memory_instr,
  output logic [31 : 0] memory_addr,
  output logic [31 : 0] memory_wdata,
  output logic [3  : 0] memory_wstrb,
  input logic [31  : 0] memory_rdata,
  input logic [0   : 0] memory_ready,
  input logic [0   : 0] meip,
  input logic [0   : 0] msip,
  input logic [0   : 0] mtip,
  input logic [63  : 0] mtime
);
  timeunit 1ns;
  timeprecision 1ps;

  agu_in_type agu_in;
  agu_out_type agu_out;
  alu_in_type alu_in;
  alu_out_type alu_out;
  bcu_in_type bcu_in;
  bcu_out_type bcu_out;
  lsu_in_type lsu_in;
  lsu_out_type lsu_out;
  csr_alu_in_type csr_alu_in;
  csr_alu_out_type csr_alu_out;
  div_in_type div_in;
  div_out_type div_out;
  mul_in_type mul_in;
  mul_out_type mul_out;
  bit_alu_in_type bit_alu_in;
  bit_alu_out_type bit_alu_out;
  bit_clmul_in_type bit_clmul_in;
  bit_clmul_out_type bit_clmul_out;
  decoder_in_type decoder_in;
  decoder_out_type decoder_out;
  compress_in_type compress_in;
  compress_out_type compress_out;
  forwarding_register_in_type forwarding_rin;
  forwarding_execute_in_type forwarding_ein;
  forwarding_out_type forwarding_out;
  csr_decode_in_type csr_din;
  csr_execute_in_type csr_ein;
  csr_out_type csr_out;
  register_read_in_type register_rin;
  register_write_in_type register_win;
  register_out_type register_out;
  fetch_in_type fetch_in_a;
  decode_in_type decode_in_a;
  execute_in_type execute_in_a;
  fetch_out_type fetch_out_y;
  decode_out_type decode_out_y;
  execute_out_type execute_out_y;
  fetch_in_type fetch_in_d;
  decode_in_type decode_in_d;
  execute_in_type execute_in_d;
  fetch_out_type fetch_out_q;
  decode_out_type decode_out_q;
  execute_out_type execute_out_q;
  mem_in_type fetchbuffer_in;
  mem_out_type fetchbuffer_out;
  mem_in_type imem_in;
  mem_out_type imem_out;
  mem_in_type dmem_in;
  mem_out_type dmem_out;

  assign fetch_in_a.f = fetch_out_y;
  assign fetch_in_a.d = decode_out_y;
  assign fetch_in_a.e = execute_out_y;
  assign decode_in_a.f = fetch_out_y;
  assign decode_in_a.d = decode_out_y;
  assign decode_in_a.e = execute_out_y;
  assign execute_in_a.f = fetch_out_y;
  assign execute_in_a.d = decode_out_y;
  assign execute_in_a.e = execute_out_y;

  assign fetch_in_d.f = fetch_out_q;
  assign fetch_in_d.d = decode_out_q;
  assign fetch_in_d.e = execute_out_q;
  assign decode_in_d.f = fetch_out_q;
  assign decode_in_d.d = decode_out_q;
  assign decode_in_d.e = execute_out_q;
  assign execute_in_d.f = fetch_out_q;
  assign execute_in_d.d = decode_out_q;
  assign execute_in_d.e = execute_out_q;

  agu agu_comp
  (
    .agu_in (agu_in),
    .agu_out (agu_out)
  );

  alu alu_comp
  (
    .alu_in (alu_in),
    .alu_out (alu_out)
  );

  bcu bcu_comp
  (
    .bcu_in (bcu_in),
    .bcu_out (bcu_out)
  );

  lsu lsu_comp
  (
    .lsu_in (lsu_in),
    .lsu_out (lsu_out)
  );

  csr_alu csr_alu_comp
  (
    .csr_alu_in (csr_alu_in),
    .csr_alu_out (csr_alu_out)
  );

  div div_comp
  (
    .reset (reset),
    .clock (clock),
    .div_in (div_in),
    .div_out (div_out)
  );

  mul #(mul_performance) mul_comp
  (
    .reset (reset),
    .clock (clock),
    .mul_in (mul_in),
    .mul_out (mul_out)
  );

  bit_alu bit_alu_comp
  (
    .bit_alu_in (bit_alu_in),
    .bit_alu_out (bit_alu_out)
  );

  bit_clmul bit_clmul_comp
  (
    .reset (reset),
    .clock (clock),
    .bit_clmul_in (bit_clmul_in),
    .bit_clmul_out (bit_clmul_out)
  );

  forwarding forwarding_comp
  (
    .forwarding_rin (forwarding_rin),
    .forwarding_ein (forwarding_ein),
    .forwarding_out (forwarding_out)
  );

  decoder decoder_comp
  (
    .decoder_in (decoder_in),
    .decoder_out (decoder_out)
  );

  compress compress_comp
  (
    .compress_in (compress_in),
    .compress_out (compress_out)
  );

  register register_comp
  (
    .reset (reset),
    .clock (clock),
    .register_rin (register_rin),
    .register_win (register_win),
    .register_out (register_out)
  );

  csr csr_comp
  (
    .reset (reset),
    .clock (clock),
    .csr_din (csr_din),
    .csr_ein (csr_ein),
    .csr_out (csr_out),
    .meip (meip),
    .msip (msip),
    .mtip (mtip),
    .mtime (mtime)
  );

  arbiter arbiter_comp
  (
    .reset (reset),
    .clock (clock),
    .imem_in (imem_in),
    .imem_out (imem_out),
    .dmem_in (dmem_in),
    .dmem_out (dmem_out),
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_ready (memory_ready)
  );

  fetchbuffer fetchbuffer_comp
  (
    .reset (reset),
    .clock (clock),
    .fetchbuffer_in (fetchbuffer_in),
    .fetchbuffer_out (fetchbuffer_out),
    .imem_out (imem_out),
    .imem_in (imem_in)
  );

  fetch_stage fetch_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .csr_out (csr_out),
    .fetchbuffer_out (fetchbuffer_out),
    .fetchbuffer_in (fetchbuffer_in),
    .a (fetch_in_a),
    .d (fetch_in_d),
    .y (fetch_out_y),
    .q (fetch_out_q)
  );

  decode_stage decode_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .decoder_out (decoder_out),
    .decoder_in (decoder_in),
    .compress_out (compress_out),
    .compress_in (compress_in),
    .agu_out (agu_out),
    .agu_in (agu_in),
    .bcu_out (bcu_out),
    .bcu_in (bcu_in),
    .register_out (register_out),
    .register_rin (register_rin),
    .forwarding_out (forwarding_out),
    .forwarding_rin (forwarding_rin),
    .csr_out (csr_out),
    .csr_din (csr_din),
    .dmem_in (dmem_in),
    .a (decode_in_a),
    .d (decode_in_d),
    .y (decode_out_y),
    .q (decode_out_q)
  );

  execute_stage execute_stage_comp
  (
    .reset (reset),
    .clock (clock),
    .alu_out (alu_out),
    .alu_in (alu_in),
    .lsu_out (lsu_out),
    .lsu_in (lsu_in),
    .csr_alu_out (csr_alu_out),
    .csr_alu_in (csr_alu_in),
    .div_out (div_out),
    .div_in (div_in),
    .mul_out (mul_out),
    .mul_in (mul_in),
    .bit_alu_out (bit_alu_out),
    .bit_alu_in (bit_alu_in),
    .bit_clmul_out (bit_clmul_out),
    .bit_clmul_in (bit_clmul_in),
    .register_win (register_win),
    .forwarding_ein (forwarding_ein),
    .csr_out (csr_out),
    .csr_ein (csr_ein),
    .dmem_out (dmem_out),
    .a (execute_in_a),
    .d (execute_in_d),
    .y (execute_out_y),
    .q (execute_out_q)
  );

endmodule
