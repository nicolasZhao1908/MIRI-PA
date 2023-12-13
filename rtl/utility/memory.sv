`include "utility/ff.sv"
`include "utility/demux.sv"
`include "utility/comparator"

module memory #(
    parameter integer unsigned FILL_DATA_WIDTH = 128,
    parameter integer unsigned SPACES = 128,
    parameter integer unsigned ADDRESS_WIDTH = 32,
    parameter integer unsigned STORE_DATA_WIDTH = 32,
    parameter integer unsigned DATA_TRANSFER_TIME = 5

) (
    input logic clk,
    input logic req,
    input logic store,
    input logic [ADDRESS_WIDTH-1:0] address,
    input logic [STORE_DATA_WIDTH-1:0] evict_data,
    output logic [FILL_DATA_WIDTH-1:0] fill_data,
    output logic response_valid

    /*
    ,output logic [0:0] enables_o [128]
    ,output logic stAndReq
    ,output logic [6:0] ctrAddr
    ,output logic [128:0] mem_o_isnt
    ,output logic [STORE_DATA_WIDTH-1:0] data_out_out [128]
    ,output logic [STORE_DATA_WIDTH-1:0] evict_data_out */

);
  //TODO NO RESET DEFINED! reset

  localparam integer unsigned CONTROL_BITS_FOR_FF_SELECTION = $clog2(SPACES);

  logic [0:0] enables[SPACES];
  logic [STORE_DATA_WIDTH-1:0] data_out[SPACES];

  demux #(
      .CTRL(CONTROL_BITS_FOR_FF_SELECTION)
  ) enable_demux (
      .inp(store & req),
      .ctrl(address[CONTROL_BITS_FOR_FF_SELECTION-1:0]),
      .out(enables)
  );

  genvar i;
  generate
    for (i = 0; i < SPACES; i++) begin : g_ff
      ff #(
          .WIDTH(STORE_DATA_WIDTH)
      ) flippyFloppy (
          .clk(clk),
          .enable(enables[i]),
          .reset(1'b0),
          .inp(evict_data),
          .out(data_out[i])
      );
      //DEBUG assign enables_o[i] = enables[i][0:0];
    end
  endgenerate

  localparam integer unsigned FF_PER_LINE = FILL_DATA_WIDTH / STORE_DATA_WIDTH;
  localparam integer unsigned LINES = SPACES / FF_PER_LINE;

  logic [FILL_DATA_WIDTH-1:0] lines_out[LINES];
  logic [$clog2(LINES) - 1:0] selected_line;
  assign selected_line = address[$clog2(LINES)+$clog2(FF_PER_LINE)-1:$clog2(FF_PER_LINE)];

  genvar i2;
  generate
    for (i = 0; i < LINES; i++) begin : g_line
      for (i2 = 0; i2 < FF_PER_LINE; i2++) begin : g_ff_line
        assign lines_out[i][(i2 + 1) * STORE_DATA_WIDTH - 1 : i2 * STORE_DATA_WIDTH] = data_out[i * FF_PER_LINE + i2];
      end
    end
  endgenerate

  logic valid_out;
  assign valid_out = req & ~store;

  logic [FILL_DATA_WIDTH:0] delayed_result;
  logic reset_bus_1_to_n;
  logic reset_bus_1;

  nff #(
      .N(DATA_TRANSFER_TIME),
      .WIDTH(FILL_DATA_WIDTH + 1)
  ) long_way_back (
      .clk(clk),
      .enable(1'b1),
      .reset_1(reset_bus_1),
      .reset_1_to_N(reset_bus_1_to_n),
      .inp({valid_out, lines_out[selected_line]}),
      .out(delayed_result)
  );

  assign fill_data = delayed_result[FILL_DATA_WIDTH-1:0];
  assign response_valid = delayed_result[FILL_DATA_WIDTH];
  assign reset_bus_1_to_n = delayed_result[FILL_DATA_WIDTH];
  assign reset_bus_1 = reset_bus_1_to_n;  // & ~req


  //DEBUG
  /*
    assign stAndReq = store & req;
    assign ctrAddr = address[CONTROL_BITS_FOR_FF_SELECTION-1:0];
    assign mem_o_isnt ={valid_out, lines_out[selected_line]};
    assign data_out_out = data_out;
    assign evict_data_out = evict_data;
    */

endmodule




