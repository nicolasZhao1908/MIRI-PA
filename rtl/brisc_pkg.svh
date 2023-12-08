`ifndef BRISC_PKG_SVH
`define BRISC_PKG_SVH 

`timescale 1ns / 1ps

package brisc_pkg;
  parameter integer unsigned ILEN = 32;
  parameter integer unsigned XLEN = 32;
  parameter integer unsigned MEM_REQ_DELAY = 5;
  parameter integer unsigned MEM_RESP_DELAY = 5;
  parameter integer unsigned BYTE_LEN = 8;
  parameter integer unsigned WORLD_LEN = 32;
  parameter integer unsigned ADDRESS_BITS = 32;
  parameter integer unsigned OPCODE_BITS = 7;
  parameter integer unsigned CACHE_LINE_LEN = 128;

  parameter logic [XLEN-1:0] PC_BOOT = 'h00001000;
  parameter logic [XLEN-1:0] PC_EXCEPT = 'h00002000;

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
  } itype_e;

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
  } instruction_e;

  typedef enum logic [OPCODE_BITS-1:0] {
    // SUB, ADD, MUL, AND, OR, XOR
    OPCODE_ALU = 7'b0110011,
    // ADDI
    OPCODE_IMM = 7'b0010011,
    // LW, LB
    OPCODE_LOAD = 7'b0000011,
    // SW, SB
    OPCODE_STORE = 7'b0100011,
    // BEQ
    OPCODE_BRANCH = 7'b1100011,
    // JAL
    OPCODE_JUMP = 7'b1101111
  } opcode_e;

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
