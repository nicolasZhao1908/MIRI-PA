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
    input pc_src_e pc_src_A_in,
    input logic icache_ready_in,
    input logic dcache_ready_in,
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
    fwd_src1_out = NONE;
    fwd_src2_out = NONE;
    stall_F_out = '0;
    stall_D_out = '0;
    flush_D_out = '0;
    flush_A_out = '0;
    load_stall_w = '0;
    pc_taken_w = '0;


    // Forwarding C -> EX or WB -> EX
    if (((rs1_A_in == rd_C_in) & reg_write_C_in) & (rs1_A_in != 0)) begin
      fwd_src1_out = FROM_C;
    end else if (((rs1_A_in == rd_WB_in) & reg_write_WB_in) & (rs1_A_in != 0)) begin
      fwd_src1_out = FROM_WB;
    end else begin
      fwd_src1_out = NONE;
    end

    if (((rs2_A_in == rd_C_in) & reg_write_C_in) & (rs2_A_in != 0)) begin
      fwd_src2_out = FROM_C;
    end else if (((rs2_A_in == rd_WB_in) & reg_write_WB_in) & (rs2_A_in != 0)) begin
      fwd_src2_out = FROM_WB;
    end else begin
      fwd_src2_out = NONE;
    end

    // Stall if a previous load instr produces
    // the value to be consumed of the next instr
    load_stall_w = (result_src_A_in == FROM_CACHE) &
                 ((rs1_D_in == rd_A_in) | (rs2_D_in == rd_A_in));
    stall_F_out = load_stall_w | ~dcache_ready_in | ~icache_ready_in;
    stall_D_out = load_stall_w | ~dcache_ready_in;
    stall_A_out = ~dcache_ready_in;
    stall_C_out = ~dcache_ready_in;

    // Flush on control hazard
    pc_taken_w = (pc_src_A_in == FROM_A);
    flush_D_out = (pc_taken_w | ~icache_ready_in) & (~stall_C_out);
    flush_A_out = (pc_taken_w | load_stall_w) & ~stall_C_out;
    flush_WB_out = ~dcache_ready_in;
  end


endmodule
