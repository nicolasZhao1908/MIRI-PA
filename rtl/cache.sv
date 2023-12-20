`include "brisc_pkg.svh"

module cache
  import brisc_pkg::*;
#(
    parameter integer unsigned NUM_CACHE_LINES = 4,
    parameter integer unsigned INPUT_WIDTH = XLEN,
    parameter integer unsigned DATA_WIDTH = XLEN
) (
    input logic clk,
    input logic read_write,
    input logic [INPUT_WIDTH- 1:0] inp,
    input logic [DATA_WIDTH - 1:0] data_in,
    input logic valid_in,
    output logic hit,
    output logic [DATA_WIDTH - 1:0] data_out

    //,output logic valid_from_lines_out[2 ** SetBits]
    //,output logic write_enables_out[2 ** SetBits]
    //,output logic [1:0] set_out
    //,output logic [INPUT_WIDTH - SetBits - 1:0] tag_out
);


  localparam int unsigned SetBits = $clog2(NUM_CACHE_LINES);
  localparam integer unsigned CacheLines = 2 ** S;
  localparam integer unsigned TagWidth = INPUT_WIDTH - SetBits;

  logic [SetBits - 1:0] set;
  assign set = inp[SetBits-1:0];

  logic [TagWidth - 1:0] tag;
  assign tag = inp[INPUT_WIDTH-1:SetBits];

  logic enables[CacheLines];

  logic [DATA_WIDTH - 1:0] data_from_lines[CacheLines];
  logic [TagWidth - 1:0] tag_from_lines[CacheLines];
  logic valid_from_lines[CacheLines];

  always_comb begin
    int unsigned i;
    for (i = 0; i < (1 << SetBits); ++i) begin : g_dm_out
      assign enables[i] = ((set == i[SetBits-1:0]) ? read_write : '0);
    end
  end

  genvar i;  //Generate the cachelines
  generate
    for (i = 0; i < CacheLines; i++) begin : g_cache_line
      cache_line #(
          .TAG_WIDTH (INPUT_WIDTH - SetBits),
          .DATA_WIDTH(DATA_WIDTH)
      ) line (
          .clk(clk),
          .write(enables[i]),
          .valid_in(valid_in),
          .tag_in(tag),
          .data_in(data_in),
          .valid_out(valid_from_lines[i]),
          .tag_out(tag_from_lines[i]),
          .data_out(data_from_lines[i])
      );
    end
  endgenerate
  assign hit = {inp[INPUT_WIDTH-1:SetBits], 1'b1} == {tag_from_lines[set], valid_from_lines[set]};
  assign data_out = data_from_lines[set];
endmodule
