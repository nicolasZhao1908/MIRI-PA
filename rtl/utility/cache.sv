`include "brisc_pkg.svh"

module cache
  import brisc_pkg::*;
#(
    parameter integer unsigned SET_BIT_WIDTH = 2,
    parameter integer unsigned INPUT_WIDTH = 32,
    parameter integer unsigned DATA_WIDTH = XLEN
) (
    input logic clk,
    input logic read_write,
    input logic [INPUT_WIDTH- 1:0] inp,
    input logic [DATA_WIDTH - 1:0] data_in,
    input logic valid_in,
    output logic hit,
    output logic [DATA_WIDTH - 1:0] data_out
);

  localparam integer unsigned TAG_WIDTH = INPUT_WIDTH - SET_BIT_WIDTH;

  logic [SET_BIT_WIDTH - 1:0] set;
  assign set = inp[SET_BIT_WIDTH-1:0];

  logic [TAG_WIDTH - 1:0] tag;
  assign tag = inp[INPUT_WIDTH-1:SET_BIT_WIDTH];

  logic write_enables[CACHE_LINES];

  logic [DATA_WIDTH - 1:0] data_from_lines[CACHE_LINES];
  logic [TAG_WIDTH - 1:0] tag_from_lines[CACHE_LINES];
  logic valid_from_lines[CACHE_LINES];


  demux #(
      .CTRL(SET_BIT_WIDTH),
      .DATA_WIDTH(1)
  ) enable_demux (
      .inp (read_write),
      .ctrl(set),
      .out (write_enables)
  );

  genvar i;
  generate
    for (i = 0; i < CACHE_LINES; i++) begin : g_cache_line
      cache_line #(
          .TAG_WIDTH (INPUT_WIDTH - SET_BIT_WIDTH),
          .DATA_WIDTH(DATA_WIDTH)
      ) line (
          .clk(clk),
          .write(write_enables[i]),
          .valid_in(valid_in),
          .tag_in(tag),
          .data_in(data_in),
          .valid_out(valid_from_lines[i]),
          .tag_out(tag_from_lines[i]),
          .data_out(data_from_lines[i])
      );
    end
  endgenerate

  assign hit = {inp[INPUT_WIDTH-1:SET_BIT_WIDTH], 1'b1} ==
        {tag_from_lines[set], valid_from_lines[set]};
  assign data_out = data_from_lines[set];

endmodule
