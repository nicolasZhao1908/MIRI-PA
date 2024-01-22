`include "brisc_pkg.svh"

module alu_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,  // high reset
    input logic flush_in,
    input logic stall_in,

    input fwd_src_e fwd_src1_in,
    input fwd_src_e fwd_src2_in,
    input [XLEN-1:0] pc_plus4_in,
    input logic [XLEN-1:0] rs1_data_in,
    input logic [XLEN-1:0] rs2_data_in,

    // FORWARDED
    input logic [XLEN-1:0] alu_res_C_in,
    input logic [XLEN-1:0] result_WB_in,

    input  logic alu_valid_in,
    output logic alu_valid_out,

    input logic [REG_BITS-1:0] rd_in,
    input logic [REG_BITS-1:0] rs1_in,
    input logic [REG_BITS-1:0] rs2_in,
    input logic [XLEN-1:0] imm_in,
    input logic [XLEN-1:0] pc_in,

    output pc_src_e pc_src_out,
    output logic [XLEN-1:0] pc_target_out,
    output logic [XLEN-1:0] alu_res_out,
    output logic [XLEN-1:0] pc_plus4_out,
    output logic [REG_BITS-1:0] rd_out,
    output logic [REG_BITS-1:0] rs1_out,
    output logic [REG_BITS-1:0] rs2_out,
    output xcpt_e xcpt_out,

    // data to write into memory (rf[rs2])
    output logic [XLEN-1:0] write_data_out,

    // IN: ctrl signals
    input logic reg_write_in,
    input alu_ctrl_e alu_ctrl_in,
    input result_src_e result_src_in,
    input alu_src1_e alu_src1_in,
    input alu_src2_e alu_src2_in,
    input logic mem_write_in,
    input logic is_branch_in,
    input logic is_jump_in,
    input data_size_e data_size_in,

    // OUT: ctrl signals
    output logic reg_write_out,
    output result_src_e result_src_out,
    output logic mem_write_out,
    output data_size_e data_size_out,

    input logic branch_prediction,
    output logic branch_prediction_wrong,
    output logic [XLEN-1:0] pc_out
);
  logic [XLEN-1:0] src1;
  logic [XLEN-1:0] src2;
  logic [XLEN-1:0] rs1_data_w;
  logic [XLEN-1:0] rs2_data_w;
  logic [XLEN-1:0] pc_next_w;

  alu_src1_e alu_src1_w;
  alu_src2_e alu_src2_w;

  alu_ctrl_e alu_ctrl_w;
  logic [XLEN-1:0] imm_w;
  logic zero_w;
  logic is_branch_w;
  logic is_jump_w;
  logic [XLEN-1:0] src2_w;

  logic branch_prediction_wrong_w;


  always_comb begin
    unique case (fwd_src1_in)
      FROM_CACHE: begin
        src1 = alu_res_C_in;
      end
      FROM_WB: begin
        src1 = result_WB_in;
      end
      default: begin
        if (alu_src1_w == FROM_PC) begin
          src1 = pc_out;
        end else begin
          src1 = rs1_data_w;
        end
      end
    endcase

    unique case (fwd_src2_in)
      FROM_CACHE: begin
        src2_w = alu_res_C_in;
      end
      FROM_WB: begin
        src2_w = result_WB_in;
      end
      default: begin
        src2_w = rs2_data_w;
      end
    endcase

    src2 = (alu_src2_w == FROM_IMM) ? imm_w : src2_w;
    write_data_out = src2_w;
    pc_src_out = pc_src_e'((is_branch_w & zero_w) | is_jump_w);
    pc_target_out = pc_out + imm_w;

    if ((pc_src_out == FROM_F) & branch_prediction) begin
      branch_prediction_wrong_w = 1;
    end else begin
      branch_prediction_wrong_w = 0;
    end


    xcpt_out = NO_XCPT;
    if (mem_write_out == 1 | result_src_out == FROM_CACHE) begin
      if ((alu_res_out[1:0] != 0) & (data_size_out == W)) begin
        xcpt_out = MEM_UNALIGNED;
      end else if (alu_res_out < PC_DATA) begin
        xcpt_out = ADDR_INVALID;
      end
    end
  end

  alu alu_unit (
      // IN
      .src1  (src1),
      .src2  (src2),
      .ctrl  (alu_ctrl_w),
      // OUT
      .zero  (zero_w),
      .result(alu_res_out)
  );


  // Pipeline registers D->E
  always_ff @(posedge clk) begin
    if (reset | flush_in) begin
      pc_plus4_out <= 0;
      rd_out <= 0;
      rs1_out <= 0;
      rs2_out <= 0;
      pc_out <= 0;
      rs1_data_w <= 0;
      rs2_data_w <= 0;
      imm_w <= 0;
      // Ctrl signals
      reg_write_out <= 0;
      result_src_out <= result_src_e'(0);
      mem_write_out <= 0;
      is_branch_w <= 0;
      is_jump_w <= 0;
      alu_src1_w <= alu_src1_e'(0);
      alu_src2_w <= alu_src2_e'(0);
      alu_ctrl_w <= alu_ctrl_e'(0);
      data_size_out <= data_size_e'(0);
      alu_valid_out <= 0;
      branch_prediction_wrong <= 0;

    end else if (~stall_in) begin
      pc_plus4_out <= pc_plus4_in;
      rd_out <= rd_in;
      rs1_out <= rs1_in;
      rs2_out <= rs2_in;
      pc_out <= pc_in;
      rs1_data_w <= rs1_data_in;
      rs2_data_w <= rs2_data_in;
      imm_w <= imm_in;
      // Ctrl signals
      reg_write_out <= reg_write_in;
      result_src_out <= result_src_in;
      mem_write_out <= mem_write_in;
      is_branch_w <= is_branch_in;
      is_jump_w <= is_jump_in;
      alu_src1_w <= alu_src1_in;
      alu_src2_w <= alu_src2_in;
      alu_ctrl_w <= alu_ctrl_in;
      data_size_out <= data_size_in;
      alu_valid_out <= alu_valid_in;
      branch_prediction_wrong <= branch_prediction_wrong_w;
    end
  end
endmodule
