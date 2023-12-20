`include "brisc_pkg.svh"

module decode_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_decode,
    input logic write_reg,
    input logic [ILEN-1:0] instr_in,
    input logic [OPCODE_BITS-1:0] opcode_wb_in,

    input logic [XLEN-1:0] write_data_in,
    input logic [RegBits-1:0] rd_in,

    output logic [RegBits-1:0] rd_out,

    output logic [XLEN-1:0] src1,
    output logic [XLEN-1:0] src2,
    output logic [XLEN-1:0] rd_data_out,
    output logic exception,
    output instr_e instr_out
);

  localparam int unsigned RegBits = $clog2(NUM_REG);
  logic i_valid;
  logic [XLEN-1:0] imm;
  logic [RegBits-1:0] rs1;
  logic [RegBits-1:0] rs2;

  logic [RegBits-1:0] rd;

  logic [XLEN-1:0] rs1_data;
  logic [XLEN-1:0] rs2_data;

  initial begin
    assign exception = 0;
  end

  idecoder idec (
      .instr(instr_in),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd_out),
      .imm(imm),
      .out_instr(instr_out),
      .i_valid(i_valid)
  );

  assign exception = !i_valid;
  assign reg_enable = opcode_wb_in == OPCODE_ALU || opcode_wb_in == OPCODE_IMM || opcode_wb_in == OPCODE_LOAD;

  regfile rfile (
      .clk(clk),
      .reset(reset),
      .rs1_addr(rs1),
      .rs2_addr((instr_out == SW || instr_out == SB) ? rd_out : rs2),
      .write_data(write_data_in),
      .rd_addr(rd_in),
      .enable(reg_enable),
      .rs1_data(rs1_data),
      .rs2_data(rs2_data)
  );
  assign src1 = (instr_out == JAL) ? '0 : rs1_data;
  assign src2 =  (instr_out == SUB || instr_out == ADD || instr_out == AND || instr_out == OR || instr_out == XOR || instr_out == MUL || instr_out== BEQ) ? rs2_data: imm;
  assign rd_data_out = rs2_data;

endmodule
