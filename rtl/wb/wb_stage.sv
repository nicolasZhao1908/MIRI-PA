`include "brisc_pkg.svh"

module wb_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_in,
    input logic [XLEN-1:0] alu_res_in,
    input logic [XLEN-1:0] read_data_in,
    input logic [XLEN-1:0] pc_plus4_in,
    input logic [REG_BITS-1:0] rd_in,
    output logic [REG_BITS-1:0] rd_out,
    // CTRL signals
    input logic reg_write_in,
    input result_src_e result_src_in,

    output logic reg_write_out,
    output logic [XLEN-1:0] result_out
);
  logic [XLEN-1:0] alu_res_w;
  logic [XLEN-1:0] read_data_w;
  logic [XLEN-1:0] pc_plus4_w;
  result_src_e result_src_w;

  always_comb begin
    unique case (result_src_w)
      FROM_ALU: begin
        assign result_out = alu_res_w;
      end
      FROM_CACHE: begin
        assign result_out = read_data_w;
      end
      FROM_PC_NEXT: begin
        assign result_out = pc_plus4_w;
      end
      default: begin
        assign result_out = 'x;
      end
    endcase
  end

  // Pipeline registers C->WB
  always_ff @(posedge clk) begin
    if (reset) begin
      alu_res_w <= 0;
      pc_plus4_w <= 0;
      rd_out <= 0;
      read_data_w <= 0;
      // CTRL SIGNALS
      result_src_w <= result_src_e'(0);
      reg_write_out <= 0;
    end else if (~stall_in) begin
      alu_res_w <= alu_res_in;
      pc_plus4_w <= pc_plus4_in;
      rd_out <= rd_in;
      read_data_w <= read_data_in;
      // CTRL SIGNALS
      result_src_w <= result_src_in;
      reg_write_out <= reg_write_in;
    end
  end

endmodule
