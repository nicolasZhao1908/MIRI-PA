`include "utility/ff.sv"

module cache_line #(
    parameter integer unsigned TAG_WIDTH  = 30,
    parameter integer unsigned DATA_WIDTH = 32
) (
    input logic clk,
    input logic write,
    input logic valid_in,
    input logic [TAG_WIDTH - 1:0] tag_in,
    input logic [DATA_WIDTH -1:0] data_in,
    output logic valid_out,
    output logic [TAG_WIDTH - 1:0] tag_out,
    output logic [DATA_WIDTH -1:0] data_out
);

  ff valid (
      .clk(clk),
      .enable(write),
      .inp(valid_in),
      .out(valid_out),
      .reset()
  );
  ff #(
      .WIDTH(TAG_WIDTH)
  ) tag (
      .clk(clk),
      .enable(write),
      .inp(tag_in),
      .out(tag_out),
      .reset()
  );
  ff #(
      .WIDTH(DATA_WIDTH)
  ) data (
      .clk(clk),
      .enable(write),
      .inp(data_in),
      .out(data_out),
      .reset()
  );

endmodule
