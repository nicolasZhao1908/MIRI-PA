`include "brisc_pkg.svh"

module cache_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic [XLEN-1:0] alu_res_in,
    input logic [XLEN-1:0] write_data_in,
    input logic [XLEN-1:0] pc_plus4_in,
    input logic [REG_BITS-1:0] rd_in,
    output logic [XLEN-1:0] alu_res_out,
    output logic [XLEN-1:0] read_data_out,
    output logic [XLEN-1:0] pc_plus4_out,
    output logic [REG_BITS-1:0] rd_out,
    output logic [XLEN-1:0] write_data_out,

    // CTRL SIGNALS
    input logic reg_write_in,
    input result_src_e result_src_in,
    input logic mem_write_in,
    output logic mem_write_out,
    input mem_op_size_e mem_op_size_in,
    output mem_op_size_e mem_op_size_out,
    output logic reg_write_out,
    output result_src_e result_src_out
);
  // TODO
  mem_op_size_e mem_op_size_w;
  assign mem_op_size_out = mem_op_size_w;


  ff #(
      .WIDTH(XLEN)
  ) write_data_ex_c (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(write_data_in),
      .out(write_data_out)
  );

  ff #(
      .WIDTH(XLEN)
  ) alu_res_c_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(alu_res_in),
      .out(alu_res_out)
  );
  ff #(
      .WIDTH(XLEN)
  ) pc_plus4_c_ex (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(pc_plus4_in),
      .out(pc_plus4_out)
  );

  ff #(
      .WIDTH(REG_BITS)
  ) rd_ex_c (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(rd_in),
      .out(rd_out)
  );

  // CTRL SIGNALS
  ff #(
      .WIDTH(1)
  ) reg_write_ex_c (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(reg_write_in),
      .out(reg_write_out)
  );

  ff #(
      .WIDTH(2)
  ) result_src_ex_c (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(result_src_in),
      .out(result_src_out)
  );

  ff #(
      .WIDTH(1)
  ) mem_write_ex_c (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(mem_write_in),
      .out(mem_write_out)
  );

  ff #(
      .WIDTH(1)
  ) mem_op_size_EX_C (
      .clk(clk),
      .enable(1'b1),
      .reset(reset),
      .inp(mem_op_size_in),
      .out(mem_op_size_w)
  );

endmodule
