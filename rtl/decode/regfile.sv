`include "brisc_pkg.svh"

module regfile
  import brisc_pkg::XLEN;
#(
    parameter integer unsigned REG_LENGTH = XLEN,
    parameter integer unsigned REG_NUM = 32
) (
    input logic clk,
    input logic reset,

    input logic [REG_WIDTH-1:0] rs1_addr,
    input logic [REG_WIDTH-1:0] rs2_addr,
    input logic [REG_WIDTH-1:0] rd_addr,

    input logic [REG_LENGTH-1:0] write_data,
    input logic enable,

    output logic [REG_LENGTH-1:0] rs1_data,
    output logic [REG_LENGTH-1:0] rs2_data
);
  localparam integer unsigned REG_WIDTH = $clog2(REG_LENGTH);
  logic [REG_LENGTH-1:0] regs_n[REG_NUM];
  logic [REG_LENGTH-1:0] regs_q[REG_NUM];

  always_comb begin
    // default
    assign regs_n = regs_q;

    if (enable & (rd_addr != 0)) begin
      regs_n[rd_addr] = write_data;
    end
    assign rs1_data = regs_q[rs1_addr];
    assign rs2_data = regs_q[rs2_addr];
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      for (int unsigned i = 0; i < REG_NUM; ++i) begin
        regs_q[i] <= '0;
      end
    end else if (enable) begin
      regs_q <= regs_n;
    end
  end
endmodule
