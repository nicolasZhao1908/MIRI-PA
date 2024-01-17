`include "brisc_pkg.svh"

module hazard
  import brisc_pkg::*;
(
    input logic [REG_BITS-1:0] rs1_A_in,
    input logic [REG_BITS-1:0] rs2_A_in,
    input logic [REG_BITS-1:0] rs1_D_in,
    input logic [REG_BITS-1:0] rs2_D_in,
    input logic [REG_BITS-1:0] rd_A_in,
    input logic [REG_BITS-1:0] rd_C_in,
    input logic [REG_BITS-1:0] rd_WB_in,
    input logic reg_write_C_in,
    input logic reg_write_WB_in,
    input result_src_e result_src_A_in,
    input pc_src_e pc_src_in,
    input logic dcache_busy_in,
    input logic icache_busy_in,
    output fwd_src_e fwd_src1_out,
    output fwd_src_e fwd_src2_out,
    output stall_F_out,
    output stall_D_out,
    output stall_A_out,
    output stall_C_out,
    output flush_D_out,
    output flush_A_out,
    output flush_WB_out
);

  logic load_stall_w;
  logic pc_taken_w;

  always_comb begin

    // Defaults
    assign fwd_src1_out = NONE;
    assign fwd_src2_out = NONE;
    assign stall_F_out = '0;
    assign stall_D_out = '0;
    assign flush_D_out = '0;
    assign flush_A_out = '0;
    assign load_stall_w = '0;
    assign pc_taken_w = '0;


    // Forwarding C -> EX or WB -> EX
    if (((rs1_A_in == rd_C_in) & reg_write_C_in) & (rs1_A_in != 0)) begin
      assign fwd_src1_out = FROM_C;
    end else if (((rs1_A_in == rd_WB_in) & reg_write_WB_in) & (rs1_A_in != 0)) begin
      assign fwd_src1_out = FROM_WB;
    end else begin
      assign fwd_src1_out = NONE;
    end

    if (((rs2_A_in == rd_C_in) & reg_write_C_in) & (rs2_A_in != 0)) begin
      assign fwd_src2_out = FROM_C;
    end else if (((rs2_A_in == rd_WB_in) & reg_write_WB_in) & (rs2_A_in != 0)) begin
      assign fwd_src2_out = FROM_WB;
    end else begin
      assign fwd_src2_out = NONE;
    end

    // Stall if a previous load instr produces
    // the value to be consumed of the next instr
    assign load_stall_w = (result_src_A_in == FROM_CACHE) &
                 ((rs1_D_in == rd_A_in) | (rs2_D_in == rd_A_in));
    assign stall_F_out = load_stall_w | dcache_busy_in | icache_busy_in;
    assign stall_D_out = load_stall_w | dcache_busy_in;
    assign stall_C_out = dcache_busy_in;
    assign stall_A_out = dcache_busy_in;

    // Flush on control hazard
    assign pc_taken_w = (pc_src_in == FROM_A);
    assign flush_D_out = pc_taken_w | icache_busy_in;
    assign flush_A_out = load_stall_w;
    assign flush_WB_out = dcache_busy_in;
  end


endmodule
