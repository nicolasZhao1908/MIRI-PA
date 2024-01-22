`include "brisc_pkg.svh"

module wb_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic flush_in,
    input logic [XLEN-1:0] alu_res_in,
    input logic alu_valid_in,
    input logic [XLEN-1:0] mul_res_in,
    input logic mul_valid_in,
    output logic mul_valid_out,
    input logic [XLEN-1:0] read_data_in,
    input logic [XLEN-1:0] pc_plus4_in,
    input logic [REG_BITS-1:0] alu_rd_in,
    output logic [REG_BITS-1:0] alu_rd_out,
    input logic [REG_BITS-1:0] mul_rd_in,
    output logic [REG_BITS-1:0] mul_rd_out,

    // CTRL signals
    input logic reg_write_in,
    input result_src_e result_src_in,

    output logic [REG_BITS-1:0] rd_write_out,
    output logic reg_write_out,
    output logic [XLEN-1:0] result_out
);

  logic [XLEN-1:0] alu_res_w;
  logic alu_valid_w;
  logic reg_write_w;
  logic [XLEN-1:0] mul_res_w;
  logic [XLEN-1:0] read_data_w;
  logic [XLEN-1:0] pc_plus4_w;
  result_src_e result_src_w;

  always_comb begin
    result_out = 0;
    rd_write_out = 0;
    reg_write_out = 0;
    if (alu_valid_w) begin
      unique case (result_src_w)
        FROM_ALU: begin
          result_out = alu_res_w;
        end
        FROM_CACHE: begin
          result_out = read_data_w;
        end
        FROM_PC_NEXT: begin
          result_out = pc_plus4_w;
        end
        default: begin
          result_out = 'x;
        end
      endcase
      reg_write_out = reg_write_w;
      rd_write_out = alu_rd_out;
    end else if (mul_valid_out) begin
      result_out = mul_res_w;
      rd_write_out = mul_rd_out;
      reg_write_out = mul_valid_out;
    end
  end

  // Pipeline registers C->WB
  always_ff @(posedge clk) begin
    if (reset | flush_in) begin
      pc_plus4_w <= 0;
      mul_res_w <= 0;
      mul_valid_out <= 0;
      mul_rd_out <= 0;
      alu_res_w <= 0;
      alu_rd_out <= 0;
      alu_valid_w <= 0;
      read_data_w <= 0;
      // CTRL SIGNALS
      result_src_w <= result_src_e'(0);
      reg_write_w <= 0;
    end else begin
      mul_res_w <= mul_res_in;
      mul_valid_out <= mul_valid_in;
      mul_rd_out <= mul_rd_in;
      alu_res_w <= alu_res_in;
      alu_rd_out <= alu_rd_in;
      alu_valid_w <= alu_valid_in;
      pc_plus4_w <= pc_plus4_in;
      read_data_w <= read_data_in;
      // CTRL SIGNALS
      result_src_w <= result_src_in;
      reg_write_w <= reg_write_in;
    end
  end

endmodule
