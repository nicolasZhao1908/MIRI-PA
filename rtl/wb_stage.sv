`include "brisc_pkg.svh"

module wb_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
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
      end
    endcase
  end

  ff #(
      .WIDTH(XLEN)
  ) alu_res_c_wb (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(alu_res_in),
      .out(alu_res_w)
  );

  ff #(
      .WIDTH(XLEN)
  ) read_data_c_wb (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(read_data_in),
      .out(read_data_w)
  );

  ff #(
      .WIDTH(XLEN)
  ) pc_plus4_c_wb (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(pc_plus4_in),
      .out(pc_plus4_w)
  );

  result_src_e result_src_w;

  ff #(
      .WIDTH(REG_BITS)
  ) rd_c_wb (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(rd_in),
      .out(rd_out)
  );

  // CTRL SIGNALS
  ff #(
      .WIDTH(1)
  ) reg_write_c_wb (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(reg_write_in),
      .out(reg_write_out)
  );

  ff #(
      .WIDTH(2)
  ) result_src_c_wb (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(result_src_in),
      .out(result_src_w)
  );

endmodule
