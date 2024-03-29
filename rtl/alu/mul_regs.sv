`include "brisc_pkg.svh"

module mul_regs
  import brisc_pkg::*;
#(
    parameter integer LATENCY = MUL_DELAY
) (
    input logic clk,
    input logic reset,
    output logic [REGMSB-1:0] rd_out,
    output logic valids_out[LATENCY],
    input logic [REGMSB-1:0] rd_in,
    input logic [XLEN-1:0] result_in,
    output logic [XLEN-1:0] result_out,
    input logic valid_in,
    output logic valid_out,
    input xcpt_e xcpt_in,
    output xcpt_e xcpt_out
);

  struct packed {
    logic [XLEN-1:0] result;
    logic [REGMSB-1:0] rd;
    logic valid;
    xcpt_e xcpt;

  } delayed[LATENCY];

  always_comb begin
    valid_out = delayed[LATENCY-1].valid;
    result_out = delayed[LATENCY-1].result;
    rd_out = delayed[LATENCY-1].rd;
    xcpt_out = delayed[LATENCY-1].xcpt;

    for (int unsigned i = 0; i < LATENCY; i++) begin
      valids_out[i] = delayed[i].valid;
    end

  end

  always_ff @(posedge clk) begin
    if (reset) begin
      for (int unsigned i = 0; i < LATENCY; ++i) begin
        delayed[i] <= '{default: 0, xcpt: NO_XCPT};
      end
    end else begin
      delayed[0].valid <= valid_in;
      delayed[0].result <= result_in;
      delayed[0].rd <= rd_in;
      delayed[0].xcpt <= xcpt_in;
      for (int unsigned i = 0; i < LATENCY - 1; ++i) begin
        delayed[i+1] <= delayed[i];
      end
    end
  end

endmodule
