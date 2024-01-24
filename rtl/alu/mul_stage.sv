`include "brisc_pkg.svh"

module mul_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_in,
    input logic flush_in,

    input  xcpt_e xcpt_in,
    output xcpt_e xcpt_out,

    input  logic valid_in,
    output logic valid_out,

    input fwd_src_e fwd_src1_in,
    input fwd_src_e fwd_src2_in,

    input logic [XLEN-1:0] rs1_data_in,
    input logic [XLEN-1:0] rs2_data_in,

    input logic [XLEN-1:0] alu_res_C_in,
    input logic [XLEN-1:0] res_WB_in,

    input  logic [REGMSB-1:0] rs1_in,
    output logic [REGMSB-1:0] rs1_out,
    input  logic [REGMSB-1:0] rs2_in,
    output logic [REGMSB-1:0] rs2_out,
    input  logic [REGMSB-1:0] rd_in,
    output logic [REGMSB-1:0] rd_out,

    output logic [XLEN-1:0] result_out
);
  logic [XLEN-1:0] src1;
  logic [XLEN-1:0] src2;
  logic [XLEN-1:0] rs1_data_w;
  logic [XLEN-1:0] rs2_data_w;

  always_comb begin
    unique case (fwd_src1_in)
      FROM_C: begin
        src1 = alu_res_C_in;
      end
      FROM_WB: begin
        src1 = res_WB_in;
      end
      default: begin
        src1 = rs1_data_w;
      end
    endcase

    unique case (fwd_src2_in)
      FROM_C: begin
        src2 = alu_res_C_in;
      end
      FROM_WB: begin
        src2 = res_WB_in;
      end
      default: begin
        src2 = rs2_data_w;
      end
    endcase
    result_out = src1 * src2;
  end

  // Pipeline registers D -> M
  always_ff @(posedge clk) begin
    if (reset | flush_in) begin
      rs1_out <= 0;
      rs2_out <= 0;
      rs1_data_w <= 0;
      rs2_data_w <= 0;
      rd_out <= 0;
      valid_out <= 0;
      xcpt_out <= NO_XCPT;
    end else if (~stall_in) begin
      rs1_out <= rs1_in;
      rs2_out <= rs2_in;
      rs1_data_w <= rs1_data_in;
      rs2_data_w <= rs2_data_in;
      rd_out <= rd_in;
      valid_out <= valid_in;
      xcpt_out <= xcpt_in;
    end
  end
endmodule
