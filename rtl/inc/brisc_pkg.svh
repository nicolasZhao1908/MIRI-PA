`ifndef BRISC_PKG_SVH
`define BRISC_PKG_SVH 

// `timescale 1ns / 1ps added in Makefile

package brisc_pkg;
  parameter int unsigned ILEN = 32;
  parameter int unsigned XLEN = 32;
  parameter int unsigned NUM_REG = 32;
  parameter int unsigned MEM_REQ_DELAY = 5;
  parameter int unsigned MEM_RESP_DELAY = 5;
  parameter int unsigned MUL_DELAY = 5;
  parameter int unsigned BYTE_LEN = 8;
  parameter int unsigned WORD_LEN = 32;
  parameter int unsigned ADDR_LEN = 32;

  parameter int unsigned MEM_DEPTH = 1 << 13;
  parameter int unsigned OPCODE_LEN = 7;
  parameter int unsigned REGMSB = $clog2(NUM_REG);

  parameter logic [XLEN-1:0] PC_BOOT = 'h00001000;
  parameter logic [XLEN-1:0] PC_XCPT = 'h00002000;
  parameter logic [XLEN-1:0] PC_DATA = 'h00004000;

  // SUB, ADD, MUL, AND, OR, XOR
  parameter logic [OPCODE_LEN-1:0] OPCODE_R = 7'b0110011;
  // ADDI
  parameter logic [OPCODE_LEN-1:0] OPCODE_IMM = 7'b0010011;
  // LW, LB
  parameter logic [OPCODE_LEN-1:0] OPCODE_LOAD = 7'b0000011;
  // SW, SB
  parameter logic [OPCODE_LEN-1:0] OPCODE_STORE = 7'b0100011;
  // BEQ
  parameter logic [OPCODE_LEN-1:0] OPCODE_BEQ = 7'b1100011;
  // JAL
  parameter logic [OPCODE_LEN-1:0] OPCODE_JUMP = 7'b1101111;
  parameter logic [OPCODE_LEN-1:0] OPCODE_AUIPC = 7'b0010111;
  parameter logic [OPCODE_LEN-1:0] OPCODE_END = 7'b0000000;

  // ADDI x0, x0, 0
  parameter logic [ILEN-1:0] NOP = 32'h00000013;
  parameter logic [6:0] FUNCT7_MUL = 7'b0000001;


  typedef enum logic {
    FROM_PC_NEXT_F,
    FROM_A
  } pc_src_e;


  typedef enum logic [2:0] {
    I_IMM,
    S_IMM,
    B_IMM,
    J_IMM,
    U_IMM
  } imm_src_e;

  typedef enum logic [1:0] {
    ADD_OP,
    SUB_OP,
    Rtype_OP
  } alu_op_e;

  typedef enum logic [1:0] {
    FROM_ALU,
    FROM_CACHE,
    FROM_PC_NEXT
  } result_src_e;

  typedef enum logic {
    FROM_RS1,
    FROM_PC
  } alu_src1_e;

  typedef enum logic {
    FROM_RS2,
    FROM_IMM
  } alu_src2_e;

  typedef enum logic [1:0] {
    NONE,
    FROM_C,
    FROM_WB
  } fwd_src_e;

  typedef enum logic [2:0] {
    ADD,
    SUB,
    AND,
    OR,
    MUL
  } alu_ctrl_e;

  typedef enum logic {
    B,
    W
  } data_size_e;

  typedef enum logic [1:0] {
    NO_XCPT,
    MEM_UNALIGNED,
    UNDEF_INSTR,
    ADDR_INVALID
  } xcpt_e;

  /*********/
  /* CACHE */
  /*********/
  parameter int unsigned CACHE_LINE_LEN = 128;
  parameter int unsigned NUM_CACHE_LINES = 4;
  parameter int unsigned SET_LEN = $clog2(NUM_CACHE_LINES);
  parameter int unsigned BYTE_OFFSET_LEN = $clog2(WORD_LEN / BYTE_LEN);
  parameter int unsigned WORD_OFFSET_LEN = $clog2(CACHE_LINE_LEN / WORD_LEN);
  parameter int unsigned OFFSET_LEN = $clog2(CACHE_LINE_LEN / BYTE_LEN);
  parameter int unsigned TAG_LEN = ADDR_LEN - SET_LEN - OFFSET_LEN;

  // Cache structs
  // CPU request input (CPU -> Cache)
  typedef struct packed {
    logic valid;
    logic rw;
    logic [ADDR_LEN-1:0] addr;
    logic [XLEN-1:0] data;
    data_size_e size;
  } cpu_req_t;

  // Memory response (Mem -> Cache)
  typedef struct packed {
    logic ready;
    logic [ADDR_LEN-1:0] addr;
    logic [CACHE_LINE_LEN-1:0] data;
  } mem_resp_t;

  // Memory request (Cache -> Mem)
  typedef struct packed {
    logic valid;
    logic rw;
    logic [ADDR_LEN-1:0] addr;
    logic [CACHE_LINE_LEN-1:0] data;
  } mem_req_t;

  // Cache result (Cache -> CPU)
  typedef struct packed {
    logic [XLEN-1:0] data;
    logic ready;
  } cpu_result_t;

  //  Cache set = Tag store + data store
  typedef struct packed {
    logic valid;
    logic dirty;
    logic [TAG_LEN-1:0] tag;
    logic [CACHE_LINE_LEN-1:0] data;
  } cache_set_t;

  /*******/
  /* ROB */
  /*******/

  // Biggest delay should be m m m m m f f f f f F D A e m m m m m f f f f f f C WB
  parameter int unsigned ROB_NUM_ENTRIES = 1 << 5;
  parameter int unsigned ROB_NUM_REQS = 2;
  parameter int unsigned ROB_TICKET_LEN = $clog2(ROB_NUM_ENTRIES);

  typedef struct packed {
    xcpt_e xcpt;
    logic [XLEN-1:0] result;
    logic [REGMSB-1:0] dest;
    logic [$clog2(ROB_NUM_ENTRIES)-1:0] ticket;
    logic valid;
    logic reg_rw;
    logic mem_rw;
  } rob_req_t;

endpackage


`endif
