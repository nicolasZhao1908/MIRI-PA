
`include "brisc_pkg.svh"

module ifetch
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_fetch,
    input logic b_taken,
    input logic [ADDRESS_BITS-1:0] b_target,
    output logic [ILEN-1:0] instr
);
  logic [XLEN-1:0] pc_next;
  logic [XLEN-1:0] pc_curr;

  logic pc_update;

  assign pc_update = !stall_fetch;
  assign pc_next   = b_taken ? b_target : pc_curr + 4;

  ff #(
      .WIDTH(32),
      .RESET_VALUE(PC_BOOT)
  ) pc (
      .clk(clk),
      .enable(pc_update),
      .reset(reset),
      .inp(pc_next),
      .out(pc_curr)
  );

endmodule
