`include "brisc_pkg.svh"

module wb_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic [REG_BITS-1:0] rd_in,
    input logic [OPCODE_BITS-1:0] opcode_in,
    input logic [XLEN-1:0] alu_res_in,
    input logic [XLEN-1:0] mem_data_in,

    output logic [REG_BITS-1:0] rd_out,
    output logic [XLEN-1:0] rd_data_out,
    output logic write_rf
);
  assign rd_out = rd_in;
  assign rd_data_out = (opcode_in == OPCODE_LOAD) ? mem_data_in : alu_res_in;

  assign write_rf = (opcode_in == OPCODE_ALU ||
                    opcode_in == OPCODE_IMM ||
                    opcode_in == OPCODE_LOAD);
endmodule
