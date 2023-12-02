`include "utility/ff.sv"
`include "utility/demux.sv"
`include "utility/comparator"

module memory_v2BROKEN #(
    parameter FILL_DATA_WIDTH = 128,
    parameter SPACES = 128,
    parameter ADDRESS_WIDTH = 32,
    parameter STORE_DATA_WIDTH = 32,
    parameter DATA_TRANSFER_TIME = 5

) (
    input logic clk,
    input logic req,
    input logic store,
    input logic [ADDRESS_WIDTH-1:0] address,
    input  logic [STORE_DATA_WIDTH-1:0] evict_data,
    output logic [FILL_DATA_WIDTH-1:0] fill_data,
    output logic response_valid
);
    localparam DMX_CONTROL_SIZE = $clog2(SPACES);


    logic enables [SPACES];
    logic [STORE_DATA_WIDTH-1:0] data_out_raw [SPACES];


    demux #(.CONTROL(DMX_CONTROL_SIZE)) enable_dmx (req & store, address[DMX_CONTROL_SIZE - 1:0], enables);

    genvar i;
    generate
        for(i = 0; i < SPACES; i++) begin
            ff #(.WIDTH(STORE_DATA_WIDTH)) memff (clk, enables[i], 1'b0, evict_data, data_out_raw[i]);
        end
    endgenerate

    localparam FF_PER_LINE = FILL_DATA_WIDTH / STORE_DATA_WIDTH;
    localparam LINES = SPACES / FF_PER_LINE;

    logic [FILL_DATA_WIDTH-1:0] data_out_lines [LINES];

    genvar line;
    genvar inLine;

    generate
        for(line = 0; line < LINES; line++) begin
            for(inLine = 0; inLine < FF_PER_LINE; inLine++) begin
                assign data_out_lines [line][(inLine + 1) * STORE_DATA_WIDTH - 1 : inLine * STORE_DATA_WIDTH] = data_out_raw[line * FF_PER_LINE + inLine];
            end
        end
    endgenerate


    logic reset_bus_1;
    logic reset_bus_1_to_n;

    logic [FILL_DATA_WIDTH:0] delayed_result;

    logic [FILL_DATA_WIDTH:0] cables [6];
    nff #(.N(DATA_TRANSFER_TIME), .WIDTH(FILL_DATA_WIDTH + 1)) long_way_back (clk, 1'b1, reset_bus_1, reset_bus_1_to_n, {(~store & req), data_out_lines[address[DMX_CONTROL_SIZE-$clog2(FF_PER_LINE)-1:0]]}, delayed_result, cables);

    assign response_valid = delayed_result[FILL_DATA_WIDTH];
    assign reset_bus_1_to_n = response_valid;
    assign reset_bus_1 = response_valid;

    assign fill_data = delayed_result[FILL_DATA_WIDTH-1:0];

endmodule








module memory #(
    parameter FILL_DATA_WIDTH = 128,
    parameter SPACES = 128,
    parameter ADDRESS_WIDTH = 32,
    parameter STORE_DATA_WIDTH = 32,
    parameter DATA_TRANSFER_TIME = 5

) (
    input logic clk,
    input logic req,
    input logic store,
    input logic [ADDRESS_WIDTH-1:0] address,
    input  logic [STORE_DATA_WIDTH-1:0] evict_data,
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

   localparam CONTROL_BITS_FOR_FF_SELECTION = $clog2(SPACES);

    logic [0:0] enables[SPACES];
    logic [STORE_DATA_WIDTH-1:0] data_out[SPACES];

    demux #(.CONTROL(CONTROL_BITS_FOR_FF_SELECTION)) enable_demux (store & req, address[CONTROL_BITS_FOR_FF_SELECTION-1:0], enables);

    genvar i;
    generate
        for(i = 0; i < SPACES; i++) begin
            ff #(.WIDTH(STORE_DATA_WIDTH)) flippyFloppy (clk, enables[i], 1'b0, evict_data, data_out[i]);
            //DEBUG assign enables_o[i] = enables[i][0:0];
        end
    endgenerate

    localparam FF_PER_LINE = FILL_DATA_WIDTH / STORE_DATA_WIDTH;
    localparam LINES = SPACES / FF_PER_LINE;

    logic [FILL_DATA_WIDTH-1:0] lines_out [LINES];
    logic [$clog2(LINES) - 1:0] selected_line;
    assign selected_line = address[$clog2(LINES) + $clog2(FF_PER_LINE) - 1: $clog2(FF_PER_LINE)];

    genvar i2;
    generate
        for(i = 0; i < LINES; i++) begin
            for(i2 = 0; i2 < FF_PER_LINE; i2++) begin
                assign lines_out[i][(i2 + 1) * STORE_DATA_WIDTH - 1 : i2 * STORE_DATA_WIDTH] = data_out[i * FF_PER_LINE + i2];
            end
        end
    endgenerate

    logic valid_out;
    assign valid_out = req & ~store;

    logic [FILL_DATA_WIDTH:0] delayed_result;
    logic reset_bus_1_to_n;
    logic reset_bus_1;

    nff #(.N(DATA_TRANSFER_TIME), .WIDTH(FILL_DATA_WIDTH + 1)) long_way_back (clk, 1'b1, reset_bus_1, reset_bus_1_to_n, {valid_out, lines_out[selected_line]}, delayed_result);

    assign fill_data = delayed_result[FILL_DATA_WIDTH - 1:0];
    assign response_valid = delayed_result[FILL_DATA_WIDTH];
    assign reset_bus_1_to_n = delayed_result[FILL_DATA_WIDTH];
    assign reset_bus_1 = reset_bus_1_to_n; // & ~req


    //DEBUG
    /*
    assign stAndReq = store & req;
    assign ctrAddr = address[CONTROL_BITS_FOR_FF_SELECTION-1:0];
    assign mem_o_isnt ={valid_out, lines_out[selected_line]};
    assign data_out_out = data_out;
    assign evict_data_out = evict_data;
    */

endmodule




