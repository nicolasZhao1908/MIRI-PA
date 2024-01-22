`include "brisc_pkg.svh"

module forward
  import brisc_pkg::*;
(
    input logic [REG_BITS-1:0] rs1_A_in,
    input logic [REG_BITS-1:0] rs2_A_in,
    input logic [REG_BITS-1:0] rd_C_in,
    input logic [REG_BITS-1:0] mul_rd_WB_in,
    input logic [REG_BITS-1:0] alu_rd_WB_in,
    input logic mul_valid_WB_in,
    input logic reg_write_C_in,
    input logic reg_write_WB_in,
    output fwd_src_e fwd_src1_out,
    output fwd_src_e fwd_src2_out
);

  always_comb begin

    // Defaults
    fwd_src1_out = NONE;
    fwd_src2_out = NONE;

    // Forwarding C -> EX or WB -> EX
    if (((rs1_A_in == rd_C_in) & reg_write_C_in) & (rs1_A_in != 0)) begin
      fwd_src1_out = FROM_C;
    end else if (((((rs1_A_in == alu_rd_WB_in) & reg_write_WB_in) |((rs1_A_in == mul_rd_WB_in) & mul_valid_WB_in))) & (rs1_A_in != 0)) begin
      fwd_src1_out = FROM_WB;
    end else begin
      fwd_src1_out = NONE;
    end

    if (((rs2_A_in == rd_C_in) & reg_write_C_in) & (rs2_A_in != 0)) begin
      fwd_src2_out = FROM_C;
    end else if (((((rs2_A_in == alu_rd_WB_in) & reg_write_WB_in) |((rs2_A_in == mul_rd_WB_in) & mul_valid_WB_in))) & (rs2_A_in != 0)) begin
      fwd_src2_out = FROM_WB;
    end else begin
      fwd_src2_out = NONE;
    end
  end
endmodule
