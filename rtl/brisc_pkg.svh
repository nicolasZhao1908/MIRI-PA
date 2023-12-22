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
  parameter int unsigned WORLD_LEN = 32;
  parameter int unsigned ADDRESS_BITS = 32;
  parameter int unsigned OPCODE_BITS = 7;
  parameter int unsigned CACHE_LINE_LEN = 128;
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
  typedef enum logic [0:0] {
    USER       = 1'b0,
    SUPERVISOR = 1'b1
  } priv_mode_e;

  typedef enum logic [2:0] {
    I = 3'b000,
    R = 3'b001,
    S = 3'b010,
    B = 3'b011,
    J = 3'b100,
    INVALID = 3'b111
  } instr_type_e;

  typedef enum logic [4:0] {
    LW   = 5'b00000,
    LB   = 5'b00001,
    ADDI = 5'b00010,
    SUB  = 5'b00011,
    ADD  = 5'b00100,
    AND  = 5'b00101,
    OR   = 5'b00110,
    XOR  = 5'b00111,
    MUL  = 5'b01000,
    SW   = 5'b01001,
    SB   = 5'b01010,
    BEQ  = 5'b01011,
    JAL  = 5'b01100
  } instr_e;

  // SUB, ADD, MUL, AND, OR, XOR
  parameter logic [OPCODE_BITS-1:0] OPCODE_ALU = 7'b0110011;
  // ADDI
  parameter logic [OPCODE_BITS-1:0] OPCODE_IMM = 7'b0010011;
  // LW, LB
  parameter logic [OPCODE_BITS-1:0] OPCODE_LOAD = 7'b0000011;
  // SW, SB
  parameter logic [OPCODE_BITS-1:0] OPCODE_STORE = 7'b0100011;
  // BEQ
  parameter logic [OPCODE_BITS-1:0] OPCODE_BRANCH = 7'b1100011;
  // JAL
  parameter logic [OPCODE_BITS-1:0] OPCODE_JUMP = 7'b1101111;


  parameter logic [6:0] FUNCT7_MUL = 7'b0000001;
  parameter logic [2:0] FUNCT3_MUL = 3'b000;

  parameter logic [6:0] FUNCT7_SUB = 7'b0100000;
  parameter logic [2:0] FUNCT3_SUB = 3'b000;

  parameter logic [6:0] FUNCT7_ADD = 7'b0000000;
  parameter logic [2:0] FUNCT3_ADD = 3'b000;

  parameter logic [6:0] FUNCT7_AND = 7'b0000000;
  parameter logic [2:0] FUNCT3_AND = 3'b111;

  parameter logic [6:0] FUNCT7_OR = 7'b0000000;
  parameter logic [2:0] FUNCT3_OR = 3'b110;

  parameter logic [6:0] FUNCT7_XOR = 7'b0000000;
  parameter logic [2:0] FUNCT3_XOR = 3'b100;

  parameter logic [2:0] FUNCT3_LB = 3'b000;
  parameter logic [2:0] FUNCT3_LW = 3'b010;

  parameter logic [2:0] FUNCT3_SB = 3'b000;
  parameter logic [2:0] FUNCT3_SW = 3'b010;

  parameter logic [2:0] FUNCT3_BEQ = 3'b000;

  parameter logic [ILEN-1:0] NOP = 32'h00000013;

endpackage

`endif
