
`include "brisc_pkg.svh"

module ifetch
  import brisc_pkg::*;
(
    input logic clk,
    input logic rst,
    output logic [ILEN-1:0] instr
    // input logic boot_addr,
    // input logic priv_mode,
    // input logic b_taken,
    // input logic [ADDRESS_BITS-1:0] b_addr,
);
  logic [REG_LEN-1:0] pc_next;
  logic [REG_LEN-1:0] pc_curr;
  logic mem_resp = 1'b0;

  assign pc_next = pc_curr + 4;

  ram imem (
      .clk (clk),
      .req (!rst),
      .addr(pc_curr),
      .resp(mem_resp),
      .data(instr)
  );

  ff pc (
      .clk(clk),
      .enable(mem_resp),
      .reset(rst),
      .inp(pc_next),
      .out(pc_curr)
  );
endmodule
