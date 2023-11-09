`ifndef BRISC_PKG_SVH
`define BRISC_PKG_SVH

`timescale 1ns / 1ps

package brisc_pkg;
  parameter int unsigned ILEN = 32;
  parameter int unsigned REG_LEN = 32;
  parameter int unsigned BYTE_LEN = 8;
  parameter int unsigned WORLD_LEN = 32;
  parameter int unsigned ADDRESS_BITS = 32;
  parameter int unsigned OPCODE_BITS = 7;
  parameter int unsigned CACHE_LINE_LEN = 128;

  parameter logic [REG_LEN-1:0] PC_BOOT = 32'h00001000;
  parameter logic [REG_LEN-1:0] PC_EXCEPT = 32'h00002000;

  typedef enum logic [1:0] {
    R,
    I,
    S,
    B
  } itype_e;

  typedef enum logic [4:0] {
    LW,
    LB,
    ADDI,
    SUB,
    ADD,
    MUL,
    SW,
    SB,
    BEQ,
    JUMP
  } instruction_e;

  typedef enum logic [OPCODE_BITS-1:0] {
    // LW, LB, ADDI,
    OPCODE_LOAD = 7'b0000011,
    // SUB, ADD, MUL
    OPCODE_OP = 7'b0110011,
    // SW, LB
    OPCODE_STORE = 7'b0100011,
    // BEQ, JUMP
    OPCODE_BRANCH = 7'b1100011
  } opcode_e;

  // ADDI x0, x0  0
  parameter logic [ILEN-1:0] NOP = 32'h00000013;

endpackage

`endif
