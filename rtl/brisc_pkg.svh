`ifndef BRISC_PKG_SVH
`define BRISC_PKG_SVH

`timescale 1ns / 1ps

package brisc_pkg;
  parameter integer unsigned ILEN = 32;
  parameter integer unsigned REG_LEN = 32;
  parameter integer unsigned BYTE_LEN = 8;
  parameter integer unsigned WORLD_LEN = 32;
  parameter integer unsigned ADDRESS_BITS = 32;
  parameter integer unsigned OPCODE_BITS = 7;
  parameter integer unsigned CACHE_LINE_LEN = 128;

  parameter logic [REG_LEN-1:0] PC_BOOT = 'h00001000;
  parameter logic [REG_LEN-1:0] PC_EXCEPT = 'h00002000;

  typedef enum logic [0:0] {
    User       = 1'b0,
    Supervisor = 1'b1
  } priv_mode_e;

  typedef enum logic [2:0] {
    I = 3'b000,
    R = 3'b001,
    S = 3'b010,
    B = 3'b011,
    INVALID = 3'b100
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
