`include "brisc_pkg.svh"

module regfile #(
    parameter integer unsigned XLEN = brisc_pkg::XLEN,
    parameter integer unsigned NUM_REG = brisc_pkg::NUM_REG
) (
    input logic clk,
    input logic reset,

    input logic [REGMSB-1:0] rs1_addr,
    input logic [REGMSB-1:0] rs2_addr,
    input logic [REGMSB-1:0] rd_addr,

    input logic [XLEN-1:0] write_data,
    input logic enable,

    output logic [XLEN-1:0] rs1_data,
    output logic [XLEN-1:0] rs2_data
);
  localparam integer unsigned REGMSB = $clog2(XLEN);
  logic [XLEN-1:0] regs_n[NUM_REG];
  logic [XLEN-1:0] regs_q[NUM_REG];

  always_comb begin
    // Default
    assign regs_n = regs_q;

    if (rd_addr != 0) begin
      regs_n[rd_addr] = write_data;
    end
    assign rs1_data = regs_q[rs1_addr];
    assign rs2_data = regs_q[rs2_addr];
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      for (int unsigned i = 0; i < NUM_REG; ++i) begin
        regs_q[i] <= '0;
      end
    end else if (enable) begin
      regs_q <= regs_n;
    end
  end
endmodule
