`include "brisc_pkg.svh"

module memory #(
    parameter integer unsigned FILL_DATA_WIDTH = 128,
    parameter integer unsigned SPACES = 128 * 4,
    parameter integer unsigned ADDRESS_WIDTH = 32,
    parameter integer unsigned STORE_DATA_WIDTH = 8,
    parameter integer unsigned DATA_TRANSFER_TIME = 5

) (
    input logic clk,
    input logic req,
    input logic store,
    input logic storeWord,
    input logic [ADDRESS_WIDTH-1:0] address,
    input logic [(32 / STORE_DATA_WIDTH) * STORE_DATA_WIDTH-1:0] evict_data,
    output logic [FILL_DATA_WIDTH-1:0] fill_data,
    output logic response_valid


    // ,output logic [0:0] enables_o [512]
    // ,output logic [STORE_DATA_WIDTH-1:0] data_out_out [128*4]
    // ,output logic [31:0] evictD
    /*,output logic stAndReq
    ,output logic [6:0] ctrAddr
    ,output logic [128:0] mem_o_isnt
    ,output logic [STORE_DATA_WIDTH-1:0] evict_data_out */

);
  //TODO NO RESET DEFINED! reset

  localparam integer unsigned ControlBits = $clog2(SPACES);
  localparam integer unsigned FFperWord = 32 / STORE_DATA_WIDTH;

  logic [0:0] enables[SPACES];
  logic [0:0] enables_byte[SPACES];
  logic [0:0] enables_word[SPACES];
  logic [FFperWord-1:0] enables_word_raw[SPACES / FFperWord];

  logic [STORE_DATA_WIDTH-1:0] data_out[SPACES];

  demux #(
      .CTRL(ControlBits)
  ) enable_demux_store_byte (
      .inp (store & req),
      .ctrl(address[ControlBits-1:0]),
      .out (enables_byte)
  );

  demux #(
      .CTRL(ControlBits - $clog2(FFperWord)),
      .DATA_WIDTH(FFperWord)
  ) enable_demux_store_word (
      .inp ({FFperWord{store & req}}),
      .ctrl(address[ControlBits-1:$clog2(FFperWord)]),
      .out (enables_word_raw)
  );



  genvar ienables;
  generate
    for (ienables = 0; ienables < SPACES; ienables++) begin : gen_arraymapping_enables
      assign enables_word[ienables] = enables_word_raw[ienables/FFperWord][ienables%FF_PER_LINE];
    end
  endgenerate

  assign enables = storeWord ? enables_word : enables_byte;
  // assign enables_o = enables;

  logic [FFperWord * STORE_DATA_WIDTH-1:0] internal_evict_data;
  assign internal_evict_data = storeWord ? evict_data : {FFperWord{evict_data[STORE_DATA_WIDTH - 1:0]}};

  // assign evictD = internal_evict_data;

  genvar i;
  genvar wordi;
  generate  //Main memory
    for (i = 0; i < SPACES / FFperWord; i++) begin : all_ff
      for (wordi = 0; wordi < FFperWord; wordi++) begin : word_ff
        ff #(
            .WIDTH(STORE_DATA_WIDTH)
        ) flippyFloppy (
            .clk(clk),
            .enable(enables[i*FFperWord+wordi]),
            .reset(1'b0),
            .inp(internal_evict_data[(wordi+1)*STORE_DATA_WIDTH-1:wordi*STORE_DATA_WIDTH]),
            .out(data_out[i*FFperWord+wordi])
        );
      end
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
  logic reset_bus;

  nff #(
      .N(DATA_TRANSFER_TIME),
      .WIDTH(FILL_DATA_WIDTH + 1)
  ) long_way_back (
      .clk(clk),
      .enable(1'b1),
      .reset(reset_bus),
      .inp({valid_out, lines_out[selected_line]}),
      .out(delayed_result)
  );

  assign fill_data = delayed_result[FILL_DATA_WIDTH-1:0];
  assign response_valid = delayed_result[FILL_DATA_WIDTH];
  assign reset_bus = delayed_result[FILL_DATA_WIDTH];


  //DEBUG
  /*
    assign data_out_out = data_out;
    assign stAndReq = store & req;
    assign ctrAddr = address[ControlBits-1:0];
    assign mem_o_isnt ={valid_out, lines_out[selected_line]};
    assign evict_data_out = evict_data;
    */

endmodule




