`include "utility/comparator.sv"
`include "utility/cache_line.sv"
`include "utility/demux.sv"

module cache #(
    parameter integer unsigned SET_BIT_WIDTH = 2,
    parameter integer unsigned INPUT_WIDTH = 32,
    parameter integer unsigned DATA_WIDTH = 32
) (
    input logic clk,
    input logic read_write,
    input logic [INPUT_WIDTH- 1:0] inp,
    input logic [DATA_WIDTH - 1:0] data_in,
    input logic valid_in,
    output logic hit,
    output logic [DATA_WIDTH - 1:0] data_out

    //,output logic valid_from_lines_out[2 ** SET_BIT_WIDTH]
    //,output logic write_enables_out[2 ** SET_BIT_WIDTH]
    //,output logic [1:0] set_out
    //,output logic [INPUT_WIDTH - SET_BIT_WIDTH - 1:0] tag_out
);


  localparam integer unsigned CACHE_LINES = 2 ** SET_BIT_WIDTH;
  localparam integer unsigned TAG_WIDTH = INPUT_WIDTH - SET_BIT_WIDTH;

  logic [SET_BIT_WIDTH - 1:0] set;
  assign set = inp[SET_BIT_WIDTH-1:0];

  logic [TAG_WIDTH - 1:0] tag;
  assign tag = inp[INPUT_WIDTH-1:SET_BIT_WIDTH];

  logic write_enables[CACHE_LINES];

  logic [DATA_WIDTH - 1:0] data_from_lines[CACHE_LINES];
  logic [TAG_WIDTH - 1:0] tag_from_lines[CACHE_LINES];
  logic valid_from_lines[CACHE_LINES];


  demux #(.CTRL(SET_BIT_WIDTH), .WIDTH(1)) enable_demux (
      .inp(read_write),
      .ctrl(set),
      .out(write_enables)
  );

  genvar i;  //Generate the cachelines
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

  comparator #(
      .WIDTH(TAG_WIDTH + 1)
  ) hit_cmp (
      .in_1({inp[INPUT_WIDTH-1:SET_BIT_WIDTH], 1'b1}),
      .in_2({tag_from_lines[set], valid_from_lines[set]}),
      .is_equal(hit)
  );
  assign data_out = data_from_lines[set];

  //assign valid_from_lines_out = valid_from_lines;
  //assign write_enables_out = write_enables;
  //assign set_out = set;
  //assign tag_out = tag_from_lines[set];
endmodule