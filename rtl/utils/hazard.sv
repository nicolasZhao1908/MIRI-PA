`include "brisc_pkg.svh"

module hazard
  import brisc_pkg::*;
(
    input logic [REGMSB-1:0] rs1_D_in,
    input logic [REGMSB-1:0] rs2_D_in,
    input logic [REGMSB-1:0] rd_A_in,
    input result_src_e result_src_A_in,
    input pc_src_e pc_src_A_in,
    input logic icache_ready_in,
    input logic dcache_ready_in,
    input logic valids_M_in[MUL_DELAY],
    output logic stall_F_out,
    output logic stall_D_out,
    output logic stall_A_out,
    output logic stall_C_out,
    output logic flush_D_out,
    output logic flush_A_out,
    output logic flush_C_out,
    output logic flush_WB_out,
    input logic pred_wrong_D_in,
    input xcpt_e xcpt_WB_in
);

  logic load_stall_w;
  logic pc_taken_w;
  logic mul_stall;

  always_comb begin

    // Defaults
    stall_F_out = '0;
    stall_D_out = '0;
    flush_D_out = '0;
    flush_A_out = '0;
    load_stall_w = '0;
    pc_taken_w = '0;
    mul_stall = '0;

    for (int unsigned i = 0; i < MUL_DELAY; i++) begin
      if (valids_M_in[i]) begin
        mul_stall = 1;
      end
    end

    // Stall if a previous load instr produces
    // the value to be consumed of the next instr
    load_stall_w = (result_src_A_in == FROM_CACHE) &
                 ((rs1_D_in == rd_A_in) | (rs2_D_in == rd_A_in));
    stall_F_out = load_stall_w | ~dcache_ready_in | ~icache_ready_in | mul_stall;
    stall_D_out = load_stall_w | ~dcache_ready_in | mul_stall | (~icache_ready_in & ~dcache_ready_in);
    stall_A_out = ~dcache_ready_in | mul_stall | (~icache_ready_in & ~dcache_ready_in);
    stall_C_out = ~dcache_ready_in;

    // Flush on control hazard
    pc_taken_w = (pc_src_A_in == FROM_A);
    flush_D_out = ((pc_taken_w | ~icache_ready_in) & dcache_ready_in) | pred_wrong_D_in | (xcpt_WB_in != NO_XCPT);
    flush_A_out = ((pc_taken_w | load_stall_w) & dcache_ready_in) | pred_wrong_D_in | (xcpt_WB_in != NO_XCPT);
    flush_C_out = mul_stall | (xcpt_WB_in != NO_XCPT);
    flush_WB_out = ~dcache_ready_in | (xcpt_WB_in != NO_XCPT);
  end


endmodule
