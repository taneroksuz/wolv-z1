import configure::*;

module soc
(
  input logic reset,
  input logic clock,
  input logic rx,
  output logic tx,
  output logic [31 : 0] m_avl_address,
  output logic [3  : 0] m_avl_byteenable,
  output logic [0  : 0] m_avl_lock,
  output logic [0  : 0] m_avl_read,
  output logic [31 : 0] m_avl_writedata,
  output logic [0  : 0] m_avl_write,
  output logic [2  : 0] m_avl_burstcount,
  input  logic [31 : 0] m_avl_readdata,
  input  logic [1  : 0] m_avl_response,
  input  logic [0  : 0] m_avl_waitrequest,
  input  logic [0  : 0] m_avl_readdatavalid,
  input  logic [0  : 0] m_avl_writeresponsevalid
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [0  : 0] memory_valid;
  logic [0  : 0] memory_instr;
  logic [31 : 0] memory_addr;
  logic [31 : 0] memory_wdata;
  logic [3  : 0] memory_wstrb;
  logic [31 : 0] memory_rdata;
  logic [0  : 0] memory_ready;

  logic [0  : 0] rom_valid;
  logic [0  : 0] rom_instr;
  logic [31 : 0] rom_addr;
  logic [31 : 0] rom_rdata;
  logic [0  : 0] rom_ready;

  logic [0  : 0] uart_valid;
  logic [0  : 0] uart_instr;
  logic [31 : 0] uart_addr;
  logic [31 : 0] uart_wdata;
  logic [3  : 0] uart_wstrb;
  logic [31 : 0] uart_rdata;
  logic [0  : 0] uart_ready;

  logic [0  : 0] clint_valid;
  logic [0  : 0] clint_instr;
  logic [31 : 0] clint_addr;
  logic [31 : 0] clint_wdata;
  logic [3  : 0] clint_wstrb;
  logic [31 : 0] clint_rdata;
  logic [0  : 0] clint_ready;

  logic [0  : 0] avl_valid;
  logic [0  : 0] avl_instr;
  logic [31 : 0] avl_addr;
  logic [31 : 0] avl_wdata;
  logic [3  : 0] avl_wstrb;
  logic [31 : 0] avl_rdata;
  logic [0  : 0] avl_ready;

  logic [0  : 0] meip;
  logic [0  : 0] msip;
  logic [0  : 0] mtip;

  logic [63 : 0] mtime;

  logic [31 : 0] mem_addr;

  logic [31 : 0] base_addr;

  always_comb begin

    rom_valid = 0;
    uart_valid = 0;
    clint_valid = 0;
    avl_valid = 0;

    base_addr = 0;

    if (memory_valid == 1) begin
      if (memory_addr >= avl_base_addr &&
        memory_addr < avl_top_addr) begin
          rom_valid = 0;
          uart_valid = 0;
          clint_valid = 0;
          avl_valid = memory_valid;
          base_addr = rom_base_addr;
      end else if (memory_addr >= clint_base_addr &&
        memory_addr < clint_top_addr) begin
          rom_valid = 0;
          uart_valid = 0;
          clint_valid = memory_valid;
          avl_valid = 0;
          base_addr = clint_base_addr;
      end else if (memory_addr >= uart_base_addr &&
        memory_addr < uart_top_addr) begin
          rom_valid = 0;
          uart_valid = memory_valid;
          clint_valid = 0;
          avl_valid = 0;
          base_addr = uart_base_addr;
      end else if (memory_addr >= rom_base_addr &&
        memory_addr < rom_top_addr) begin
          rom_valid = memory_valid;
          uart_valid = 0;
          clint_valid = 0;
          avl_valid = 0;
          base_addr = rom_base_addr;
      end else begin
          rom_valid = 0;
          uart_valid = 0;
          clint_valid = 0;
          avl_valid = 0;
          base_addr = 0;
      end
    end

    mem_addr = memory_addr - base_addr;

    rom_instr = memory_instr;
    rom_addr = mem_addr;

    uart_instr = memory_instr;
    uart_addr = mem_addr;
    uart_wdata = memory_wdata;
    uart_wstrb = memory_wstrb;

    clint_instr = memory_instr;
    clint_addr = mem_addr;
    clint_wdata = memory_wdata;
    clint_wstrb = memory_wstrb;

    avl_instr = memory_instr;
    avl_addr = mem_addr;
    avl_wdata = memory_wdata;
    avl_wstrb = memory_wstrb;

    if (rom_ready == 1) begin
      memory_rdata = rom_rdata;
      memory_ready = rom_ready;
    end else if  (uart_ready == 1) begin
      memory_rdata = uart_rdata;
      memory_ready = uart_ready;
    end else if  (clint_ready == 1) begin
      memory_rdata = clint_rdata;
      memory_ready = clint_ready;
    end else if  (avl_ready == 1) begin
      memory_rdata = avl_rdata;
      memory_ready = avl_ready;
    end else begin
      memory_rdata = 0;
      memory_ready = 0;
    end

  end

  cpu cpu_comp
  (
    .reset (reset),
    .clock (clock),
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_ready (memory_ready),
    .meip (meip),
    .msip (msip),
    .mtip (mtip),
    .mtime (mtime)
  );

  rom rom_comp
  (
    .reset (reset),
    .clock (clock),
    .rom_valid (rom_valid),
    .rom_instr (rom_instr),
    .rom_addr (rom_addr),
    .rom_rdata (rom_rdata),
    .rom_ready (rom_ready)
  );

  uart uart_comp
  (
    .reset (reset),
    .clock (clock),
    .uart_valid (uart_valid),
    .uart_instr (uart_instr),
    .uart_addr (uart_addr),
    .uart_wdata (uart_wdata),
    .uart_wstrb (uart_wstrb),
    .uart_rdata (uart_rdata),
    .uart_ready (uart_ready),
    .uart_rx (rx),
    .uart_tx (tx)
  );

  clint clint_comp
  (
    .reset (reset),
    .clock (clock),
    .clint_valid (clint_valid),
    .clint_instr (clint_instr),
    .clint_addr (clint_addr),
    .clint_wdata (clint_wdata),
    .clint_wstrb (clint_wstrb),
    .clint_rdata (clint_rdata),
    .clint_ready (clint_ready),
    .clint_msip (msip),
    .clint_mtip (mtip),
    .clint_mtime (mtime)
  );

  avl avl_comp
  (
    .reset (reset),
    .clock (clock),
    .avl_valid (avl_valid),
    .avl_instr (avl_instr),
    .avl_addr (avl_addr),
    .avl_wdata (avl_wdata),
    .avl_wstrb (avl_wstrb),
    .avl_rdata (avl_rdata),
    .avl_ready (avl_ready),
    .m_avl_address (m_avl_address),
    .m_avl_byteenable (m_avl_byteenable),
    .m_avl_lock (m_avl_lock),
    .m_avl_read (m_avl_read),
    .m_avl_writedata (m_avl_writedata),
    .m_avl_write (m_avl_write),
    .m_avl_burstcount (m_avl_burstcount),
    .m_avl_readdata (m_avl_readdata),
    .m_avl_response (m_avl_response),
    .m_avl_waitrequest (m_avl_waitrequest),
    .m_avl_readdatavalid (m_avl_readdatavalid),
    .m_avl_writeresponsevalid (m_avl_writeresponsevalid)
  );

endmodule
