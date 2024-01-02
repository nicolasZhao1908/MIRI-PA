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
  parameter int unsigned BYTE_LEN = 8;
  parameter int unsigned WORD_LEN = 32;
  parameter int unsigned ADDRESS_BITS = 32;
  parameter int unsigned OPCODE_BITS = 7;
  parameter int unsigned CACHE_LINE_LEN = 128;
  parameter int unsigned MEM_SIZE = 1 << 32 ;
  parameter int unsigned CACHE_LINES = 4;
  parameter int unsigned REG_BITS = $clog2(NUM_REG);

  parameter logic [XLEN-1:0] PC_BOOT = 'h00001000;
  parameter logic [XLEN-1:0] PC_XCPT = 'h00002000;

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

  typedef enum logic [1:0] {
    I_IMM = 2'b00,
    S_IMM = 2'b01,
    B_IMM = 2'b10,
    J_IMM = 2'b11
  } imm_src_e;

  typedef enum logic [1:0] {
    ADD_OP   = 2'b00,
    SUB_OP   = 2'b01,
    Rtype_OP = 2'b10
  } alu_op_e;

  typedef enum logic [1:0] {
    FROM_ALU = 2'b00,
    FROM_CACHE = 2'b01,
    FROM_PC_NEXT = 2'b10
  } result_src_e;

  typedef enum logic {
    FROM_RS2 = 1'b0,
    FROM_IMM = 1'b1
  } alu_src_e;

  typedef enum logic {
    FROM_F = 1'b0,
    FROM_EX = 1'b1
  }pc_src_e ;

  typedef enum logic [1:0] {
    NONE = 2'b00,
    FROM_C = 2'b01,
    FROM_WB = 2'b10
  }fwd_src_e ;

  typedef enum logic [1:0] {
    ADD = 2'b00,
    SUB = 2'b01,
    AND = 2'b10,
    OR  = 2'b11
  } alu_ctrl_e;

  typedef enum logic  {
    B = 1'b0,
    W = 1'b1
  } mem_op_size_e;

  // typedef enum logic [2:0] {
  //   I = 3'b000,
  //   R = 3'b001,
  //   S = 3'b010,
  //   B = 3'b011,
  //   J = 3'b100,
  //   INVALID = 3'b111
  // } instr_type_e;

  // typedef enum logic [4:0] {
  //   LW   = 5'b00000,
  //   LB   = 5'b00001,
  //   ADDI = 5'b00010,
  //   SUB  = 5'b00011,
  //   ADD  = 5'b00100,
  //   AND  = 5'b00101,
  //   OR   = 5'b00110,
  //   XOR  = 5'b00111,
  //   MUL  = 5'b01000,
  //   SW   = 5'b01001,
  //   SB   = 5'b01010,
  //   BEQ  = 5'b01011,
  //   JAL  = 5'b01100
  // } instr_e;

  // SUB, ADD, MUL, AND, OR, XOR
  parameter logic [OPCODE_BITS-1:0] OPCODE_R = 7'b0110011;
  // ADDI
  parameter logic [OPCODE_BITS-1:0] OPCODE_IMM = 7'b0010011;
  // LW, LB
  parameter logic [OPCODE_BITS-1:0] OPCODE_LOAD = 7'b0000011;
  // SW, SB
  parameter logic [OPCODE_BITS-1:0] OPCODE_STORE = 7'b0100011;
  // BEQ
  parameter logic [OPCODE_BITS-1:0] OPCODE_BEQ = 7'b1100011;
  // JAL
  parameter logic [OPCODE_BITS-1:0] OPCODE_JUMP = 7'b1101111;

  // ADDI x0, x0, 0
  parameter logic [ILEN-1:0] NOP = 32'h00000013;

endpackage

`endif
