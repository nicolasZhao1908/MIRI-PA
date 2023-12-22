`include "brisc_pkg.svh"

module ex_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,  // high reset
    input logic stall_ex,
    input instr_e instr_in,
    input logic [XLEN-1:0] rs1_data_in,
    input logic [XLEN-1:0] rs2_data_in,
    input logic [REG_BITS-1:0] rd_in,
    input logic [XLEN-1:0] imm_in,

    output logic b_taken,
    output logic [XLEN-1:0] alu_res,
    output instr_e instr_out,
    output logic [REG_BITS-1:0] rd_out
);
  logic [XLEN-1:0] alu_res_w;
  logic b_taken_w;

  alu alu_unit (
      .rs1_data_in(rs1_data_in),
      .rs2_data_in(rs2_data_in),
      .imm_in(imm_in),
      .instr(instr_in),
      .b_taken(b_taken_w),
      .alu_res(alu_res_w)
  );

  always_ff @(posedge clk) begin
    instr_out <= instr_in;
    rd_out <= rd_in;
    b_taken <= b_taken_w;
    alu_res <= alu_res_w;
  end

endmodule
