`include "brisc_pkg.svh"

module ex
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,  // high reset
    input logic stall_ex,
    input logic [XLEN-1:0] rs1_data,
    input logic [XLEN-1:0] rs2_data,
    input logic [XLEN-1:0] rd_data,
    input logic [XLEN-1:0] imm,
    input instr_e instr_in,
    input instr_type_e instr_type,
    output logic b_taken,
    output logic [XLEN-1:0] alu_res,
    output logic [XLEN-1:0] mul_res,
    output instr_e instr_out
);

  logic [4:0] instr_bus;
  logic [XLEN-1:0] delayed_res;
  logic [XLEN-1:0] src1, src2;

  assign src1 = (instr_type == J) ? '0 : rs1_data;
  assign src2 = (instr_type == R || instr_type == B) ? rs2_data : imm;


  alu #(
      .WIDTH(XLEN)
  ) alu_unit (
      .src1(src1),
      .src2(src2),
      .instr(instr_in),
      .b_taken(b_taken),
      .alu_res(alu_res)
  );

  shift_reg #(
      .WIDTH(XLEN),
      .N(MUL_DELAY)
  ) alu_res_delay (
      .clk(clk),
      .enable(stall_ex),
      .reset(reset),
      .data_in(alu_res),
      .data_out(delayed_res)
  );

  shift_reg #(
      .WIDTH(5),
      .N(MUL_DELAY)
  ) instr_delay (
      .clk(clk),
      .enable(stall_ex),
      .reset(reset),
      .data_in(instr_in),
      .data_out(instr_bus)
  );

endmodule
