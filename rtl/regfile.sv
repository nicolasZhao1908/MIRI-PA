`include "brisc_pkg.svh"

module regfile
  import brisc_pkg::XLEN;
#(
    parameter integer unsigned REG_LENGTH = XLEN,
    parameter integer unsigned REG_NUM = 32
) (
    input logic clk,
    input logic reset,

    input logic [RegBits-1:0] rs1_addr,
    input logic [RegBits-1:0] rs2_addr,
    input logic [RegBits-1:0] rd_addr,

    input logic [REG_LENGTH-1:0] write_data,
    input logic enable,

    output logic [REG_LENGTH-1:0] rs1_data,
    output logic [REG_LENGTH-1:0] rs2_data
);
  localparam integer unsigned RegBits = $clog2(REG_LENGTH);
  logic [REG_LENGTH-1:0] regs[REG_NUM];
  logic [REG_LENGTH-1:0] enables;

  always_comb begin : set_enable_and_read
    for (integer unsigned i = 0; i < REG_NUM; i++) begin
      assign enables[i] = (rd_addr == 5'(i)) ? enable : 1'b0;
    end
    assign rs1_data = regs[rs1_addr];
    assign rs2_data = regs[rs2_addr];
  end

  genvar i;
  generate
    for ( i = 0; i < REG_NUM; ++i) begin : g_registers
      ff register (
          .clk(clk),
          .enable(enables[i]),
          .reset(reset),
          .inp(write_data),
          .out(regs[i])
      );
    end
  endgenerate


endmodule
