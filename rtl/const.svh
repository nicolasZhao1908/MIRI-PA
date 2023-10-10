`ifndef CONST_SVH
`define CONST_SVH

`timescale 1ns/1ps

`define PC_BOOT 32'h00001000
`define PC_EXCEPT 32'h00002000


`define ILEN 32
`define REG_LEN 32
`define BYTE_LEN 8
`define WORLD_LEN 32
`define ADDRESS_BITS 32
`define OPCODE_BITS 7


// R-type
`define OPCODE_ADD 7'b0110011
`define OPCODE_SUB 7'b0110011
`define OPCODE_MUL 7'b0110011

// I-type
`define OPCODE_LW 7'b0000011
`define OPCODE_LB 7'b0000011
`define OPCODE_ADDI 7'b0010011

// ADDI x0, x0  0
`define NOP 7'h00000013

// S-type
`define OPCODE_SW 7'b0100011
`define OPCODE_SB 7'b0100011

// B-type
`define OPCODE_BEQ 7'b1100011
`define OPCODE_JUMP 7'b1100011


`define CACHE_LINE_LEN 512


typedef enum logic [1:0] {R, I, S, B} instr_type;

`endif
