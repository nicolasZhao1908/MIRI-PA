`include "brisc_pkg.svh"

module ex_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,  // high reset
    input logic flush_in,
    input fwd_src_e fwd_src1_in,
    input fwd_src_e fwd_src2_in,
    input [XLEN-1:0] pc_plus4_in,
    input logic [XLEN-1:0] rs1_data_in,
    input logic [XLEN-1:0] rs2_data_in,

    // FORWARDED
    input logic [XLEN-1:0] alu_res_C_in,
    input logic [XLEN-1:0] result_WB_in,

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

    // data to write into memory (rf[rs2])
    output logic [XLEN-1:0] write_data_out,

    // IN: ctrl signals
    input logic reg_write_in,
    input alu_ctrl_e alu_ctrl_in,
    input result_src_e result_src_in,
    input alu_src_e alu_src_in,
    input logic mem_write_in,
    input logic is_branch_in,
    input logic is_jump_in,
    input mem_op_size_e mem_op_size_in,

    // OUT: ctrl signals
    output logic reg_write_out,
    output result_src_e result_src_out,
    output logic mem_write_out,
    output mem_op_size_e mem_op_size_out
);
  logic [XLEN-1:0] src1;
  logic [XLEN-1:0] src2;
  logic [XLEN-1:0] rs1_data_w;
  logic [XLEN-1:0] rs2_data_w;
  logic [XLEN-1:0] pc_next_w;
  logic [XLEN-1:0] pc_w;
  alu_src_e alu_src_w;
  alu_ctrl_e alu_ctrl_w;
  logic [XLEN-1:0] imm_w;
  logic zero_w;
  logic is_branch_w;
  logic is_jump_w;
  logic [XLEN-1:0] src2_w;


  always_comb begin
    unique case (fwd_src1_in)
      FROM_CACHE: begin
        src1 = alu_res_C_in;
      end
      FROM_WB: begin
        src1 = result_WB_in;
      end
      default: begin
        src1 = rs1_data_in;
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
        src2_w = rs2_data_in;
      end
    endcase

    assign src2 = (alu_src_w == FROM_IMM)? src2_w : imm_w;
    assign pc_src_out = pc_src_e'((is_branch_w & zero_w) | is_jump_w);
    assign pc_target_out = pc_w + imm_w;
    assign write_data_out = src2_w;
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

  ff #(
      .WIDTH(XLEN)
  ) pc_plus4_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(pc_plus4_in),
      .out(pc_plus4_out)
  );

  ff #(
      .WIDTH(REG_BITS)
  ) rd_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset ),
      .inp(rd_in),
      .out(rd_out)
  );

  ff #(
      .WIDTH(REG_BITS)
  ) rs1_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(rs1_in),
      .out(rs1_out)
  );

  ff #(
      .WIDTH(REG_BITS)
  ) rs2_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(rs2_in),
      .out(rs2_out)
  );

  ff #(
      .WIDTH(XLEN)
  ) pc_curr_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(pc_in),
      .out(pc_w)
  );

  ff #(
      .WIDTH(XLEN)
  ) rs1_data_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(rs1_data_in),
      .out(rs1_data_w)
  );

  ff #(
      .WIDTH(XLEN)
  ) rs2_data_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(rs2_data_in),
      .out(rs2_data_w)
  );

  ff #(
      .WIDTH(XLEN)
  ) imm_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(imm_in),
      .out(imm_w)
  );


  // CTRL SIGNALS

  ff #(
      .WIDTH(1)
  ) reg_write_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(reg_write_in),
      .out(reg_write_out)
  );
  ff #(
      .WIDTH(2)
  ) result_src_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(result_src_in),
      .out(result_src_out)
  );

  ff #(
      .WIDTH(1)
  ) mem_write_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(mem_write_in),
      .out(mem_write_out)
  );

  ff #(
      .WIDTH(1)
  ) is_branch_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(is_branch_in),
      .out(is_branch_w)
  );
  ff #(
      .WIDTH(1)
  ) is_jump_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(is_jump_in),
      .out(is_jump_w)
  );

  ff #(
      .WIDTH(1)
  ) alu_src_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(alu_src_in),
      .out(alu_src_w)
  );
  ff #(
      .WIDTH(2)
  ) alu_ctrl_decode_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(alu_ctrl_in),
      .out(alu_ctrl_w)
  );
  ff #(
      .WIDTH(1)
  ) mem_op_size_D_EX (
      .clk(clk),
      .enable(1'b1),
      .reset(flush_in | reset),
      .inp(mem_op_size_in),
      .out(mem_op_size_out)
  );



endmodule
