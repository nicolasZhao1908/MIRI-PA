`include "brisc_pkg.svh"

module icache
  import brisc_pkg::CACHE_LINE_LEN;
#(
    parameter int unsigned CACHE_LINE_SIZE = CACHE_LINE_LEN
) (
    input logic clk,

    // can only load
    // input logic load_or_store

    // always load words
    // input logic size,

    input  logic tag,
    output logic hit,
    output logic data
);



endmodule
