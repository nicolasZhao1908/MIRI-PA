`include "brisc_pkg.svh"

module fetch_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_in,
    input pc_src_e pc_src_in,
    input logic xcpt_in,
    input logic [ADDRESS_BITS-1:0] pc_target_in,
    output logic [ILEN-1:0] instr_out,
    output logic [XLEN-1:0] pc_out,
    output logic [XLEN-1:0] pc_plus4_out
);
  logic [XLEN-1:0] pc_next;

  assign pc_next = xcpt_in ? PC_XCPT : ((pc_src_in == FROM_EX) ? pc_target_in : pc_out + 4);
  assign pc_plus4_out = pc_next;

  ff #(
      .WIDTH(XLEN)
      //.RESET_VALUE(PC_BOOT)
  ) pc (
      .clk(clk),
      .enable(~stall_in),
      .reset(reset),
      .inp(pc_next),
      .out(pc_out)
  );

endmodule
