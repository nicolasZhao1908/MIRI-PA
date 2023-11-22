`include "utility/ff.sv"
`include "utility/demux.sv"

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
);
    //TODO NO RESET DEFINED! reset

   localparam CONTROL_BITS_FOR_FF_SELECTION = $clog2(SPACES);

    logic enables[SPACES];
    logic [STORE_DATA_WIDTH-1:0] data_out[SPACES];

    demux #(.CONTROL(CONTROL_BITS_FOR_FF_SELECTION)) enable_demux (store & req, address[CONTROL_BITS_FOR_FF_SELECTION-1:0], enables);

    genvar i;
    generate
        for(i = 0; i < SPACES; i++) begin
            //assign data_in[i] = data_out[i][ &
            ff #(.WIDTH(STORE_DATA_WIDTH)) flippyFloppy (clk, enables[i], 1'b0, evict_data, data_out[i]);
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

    nff #(.N(DATA_TRANSFER_TIME), .WIDTH(FILL_DATA_WIDTH + 1)) long_way_back (clk, 1'b1, 1'b0, {valid_out, lines_out[selected_line]}, delayed_result);

    assign fill_data = delayed_result[FILL_DATA_WIDTH - 1:0];
    assign response_valid = delayed_result[FILL_DATA_WIDTH];

endmodule




