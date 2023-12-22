`include "brisc_pkg.svh"

module decode_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_decode,
    input logic [ILEN-1:0] instr_in,
    input logic [OPCODE_BITS-1:0] opcode_wb_in,
    input logic [XLEN-1:0] data_wb_in,
    input logic [REG_BITS-1:0] rd_wb_in,
    input logic rf_enable,

    output logic [REG_BITS-1:0] rd_out,
    output logic [XLEN-1:0] rs1_data_out,
    output logic [XLEN-1:0] rs2_data_out,
    output logic [XLEN-1:0] imm_out,
    output logic xcpt,
    output instr_e instr_out
);

  logic i_valid;
  logic [XLEN-1:0] imm;
  logic [REG_BITS-1:0] rs1;
  logic [REG_BITS-1:0] rs2;
  logic [REG_BITS-1:0] rd;
  logic [XLEN-1:0] rs2_data;
  logic [XLEN-1:0] imm_out_w;
  instr_e instr_out_w;
  logic [XLEN-1:0] rs1_data_out_w;
  logic [XLEN-1:0] rs2_data_out_w;

  initial begin
    assign xcpt = 0;
  end


  idecoder idec (
      .instr(instr_in),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .imm(imm_out_w),
      .out_instr(instr_out_w),
      .i_valid(i_valid)
  );

  regfile rfile (
      .clk(clk),
      .reset(reset),
      .rs1_addr(rs1),
      .rs2_addr(rs2),
      .write_data(data_wb_in),
      .rd_addr(rd_wb_in),
      .enable(rf_enable),
      .rs1_data(rs1_data_out_w),
      .rs2_data(rs2_data_out_w)
  );

  assign xcpt = !i_valid;

  ff #(
      .WIDTH(REG_BITS)
  ) rd_decode (
      .clk(clk),
      .enable(~stall_decode),
      .reset(reset),
      .inp(rd),
      .out(rd_out)
  );

  ff #(
      .WIDTH(XLEN)
  ) rs1_data_decode (
      .clk(clk),
      .enable(~stall_decode),
      .reset(reset),
      .inp(rs1_data_out_w),
      .out(rs1_data_out)
  );

  ff #(
      .WIDTH(XLEN)
  ) rs2_data_decode (
      .clk(clk),
      .enable(~stall_decode),
      .reset(reset),
      .inp(rs2_data_out_w),
      .out(rs2_data_out)
  );

  ff #(
      .WIDTH(XLEN)
  ) imm_decode (
      .clk(clk),
      .enable(~stall_decode),
      .reset(reset),
      .inp(imm_out_w),
      .out(imm_out)
  );

  ff #(
      .WIDTH(5)
  ) instr_decode (
      .clk(clk),
      .enable(~stall_decode),
      .reset(reset),
      .inp(instr_out_w),
      .out(instr_out)
  );

endmodule
