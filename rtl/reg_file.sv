`include "brisc_pkg.svh"

module reg_file
  import brisc_pkg::*;
#(
    parameter int unsigned REG_BITS = $clog2(REG_LEN),
    parameter int unsigned REG_NUM  = 32
) (
    input logic [REG_BITS-1:0] rs1_addr,
    input logic [REG_BITS-1:0] rs2_addr,

    input logic [REG_BITS-1:0] rsd_addr,
    input logic [REG_LEN-1:0] write_data,
    input logic enable,

    input logic clk,
    input logic reset,

    output logic [REG_LEN-1:0] rs1_data,
    output logic [REG_LEN-1:0] rs2_data
);
  logic [REG_LEN-1:0] regs[REG_NUM];
  logic [REG_LEN-1:0] enables;

  always_comb begin : set_enable
    for (int unsigned i = 0; i < REG_NUM; i++) begin
      enables[i] = (rsd_addr == 5'(i)) ? enable : 1'b0;
    end
  end

  always_comb begin : read_data
    rs1_data = regs[rs1_addr];
    rs2_data = regs[rs2_addr];
  end

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      for (int unsigned i = 0; i < REG_NUM; i++) begin
        regs[i] <= 'b0;
      end
    end else if (enable) begin
      regs[rsd_addr] <= write_data;
    end
  end

endmodule
