`ifndef BRISC_PKG_SVH
`define BRISC_PKG_SVH 

`timescale 1ns / 1ps

package brisc_pkg;
  parameter int unsigned ILEN = 32;
  parameter int unsigned XLEN = 32;
  parameter int unsigned NUM_REG = 32;
  parameter int unsigned MEM_REQ_DELAY = 5;
  parameter int unsigned MEM_RESP_DELAY = 5;
  parameter int unsigned MUL_DELAY = 5;
  parameter int unsigned BYTE_WIDTH = 8;
  parameter int unsigned WORD_WIDTH = 32;
  parameter int unsigned ADDRESS_WIDTH = 32;
  parameter int unsigned OPCODE_WIDTH = 7;
  parameter int unsigned CACHE_LINE_WIDTH = 128;

  // [TODO]: Set correct MEM size for matrix multiply test
  // 3 matrices of 128x128 words so 128x128x4x3
  // Data address 0x4000
  // (0x4000 + 128x128x128x4x3)/4 ~= 16384 ~= 2^14
  // let's try 2^15
  // parameter int unsigned MEM_DEPTH = 1 << 15;
  parameter int unsigned MEM_DEPTH = 1 << 13;
  parameter int unsigned NUM_CACHE_LINES = 4;
  parameter int unsigned REG_BITS = $clog2(NUM_REG);

  parameter logic [XLEN-1:0] PC_BOOT = 'h00001000;
  parameter logic [XLEN-1:0] PC_XCPT = 'h00002000;
  parameter logic [XLEN-1:0] PC_DATA = 'h00004000;

  // SUB, ADD, MUL, AND, OR, XOR
  parameter logic [OPCODE_WIDTH-1:0] OPCODE_R = 7'b0110011;
  // ADDI
  parameter logic [OPCODE_WIDTH-1:0] OPCODE_IMM = 7'b0010011;
  // LW, LB
  parameter logic [OPCODE_WIDTH-1:0] OPCODE_LOAD = 7'b0000011;
  // SW, SB
  parameter logic [OPCODE_WIDTH-1:0] OPCODE_STORE = 7'b0100011;
  // BEQ
  parameter logic [OPCODE_WIDTH-1:0] OPCODE_BEQ = 7'b1100011;
  // JAL
  parameter logic [OPCODE_WIDTH-1:0] OPCODE_JUMP = 7'b1101111;
  // AUIPC
  parameter logic [OPCODE_WIDTH-1:0] OPCODE_AUIPC = 7'b0010111;

  // ADDI x0, x0, 0
  parameter logic [ILEN-1:0] NOP = 32'h00000013;


  // In RISC-V the modes are:
  // 00 User
  // 01 Supervisor
  // 10 Reserved
  // 11 Machine
  // Here we just implement supervisor and user mode
  typedef enum logic {
    USER       = 1'b0,
    SUPERVISOR = 1'b1
  } priv_mode_e;

  typedef enum logic [2:0] {
    I_IMM = 3'b000,
    S_IMM = 3'b001,
    B_IMM = 3'b010,
    J_IMM = 3'b011,
    U_IMM = 3'b100
  } imm_src_e;

  typedef enum logic [1:0] {
    ADD_OP   = 2'b00,
    SUB_OP   = 2'b01,
    Rtype_OP = 2'b10
  } alu_op_e;

  typedef enum logic [1:0] {
    FROM_ALU = 2'b00,
    FROM_CACHE = 2'b01,
    FROM_PC_NEXT = 2'b10,
    FROM_AUIPC = 2'b11
  } result_src_e;

  typedef enum logic {
    FROM_RS2 = 1'b0,
    FROM_IMM = 1'b1
  } alu_src_e;

  typedef enum logic {
    FROM_F = 1'b0,
    FROM_A = 1'b1
  } pc_src_e;

  typedef enum logic [1:0] {
    NONE = 2'b00,
    FROM_C = 2'b01,
    FROM_WB = 2'b10
  } fwd_src_e;

  typedef enum logic [1:0] {
    ADD = 2'b00,
    SUB = 2'b01,
    AND = 2'b10,
    OR  = 2'b11
  } alu_ctrl_e;


  typedef enum logic [1:0] {
    OTHER = 2'b00,
    IS_STORE = 2'b10,
    IS_LOAD = 2'b01
  } stb_ctrl_e;

  typedef enum logic {
    B = 1'b0,
    W = 1'b1
  } data_size_e;

  typedef enum logic [1:0] {
    NO_XCPT = 2'b00,
    MEM_UNALIGNED = 2'b01,
    UNDEF_INSTR = 2'b10,
    ADDR_INVALID = 2'b11
  } xcpt_e;

endpackage

`endif
