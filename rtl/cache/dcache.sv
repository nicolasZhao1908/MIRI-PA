`include "utility/fully_associative_cache.sv"
`include "utility/memory.sv"

module dcache_mem_testonly #(
    parameter SET_BIT_WIDTH = 2,
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter CACHE_LINE_WIDTH = 128
) (
    input logic clk,
    input logic store,
    input logic [ADDRESS_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] data_in,

    output logic hit,
    output logic [DATA_WIDTH-1:0] data_out
);

    logic [CACHE_LINE_WIDTH-1:0] fill_from_mem;
    logic valid_from_mem;

    logic req_to_mem;
    logic req_store_to_mem;
    logic [ADDRESS_WIDTH-1:0] req_addr_to_mem;
    logic [DATA_WIDTH-1:0] req_store_data_to_mem;

    dcache
    #(.SET_BIT_WIDTH(SET_BIT_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH), .CACHE_LINE_WIDTH(CACHE_LINE_WIDTH))
    dcache_unit
    (clk, store, addr, data_in, fill_from_mem, valid_from_mem,
    req_to_mem, req_store_to_mem, req_addr_to_mem, req_store_data_to_mem, hit, data_out);

    memory
    #(.FILL_DATA_WIDTH(CACHE_LINE_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .STORE_DATA_WIDTH(DATA_WIDTH))
    mem
    (clk, req_to_mem, req_store_to_mem, req_addr_to_mem, req_store_data_to_mem, fill_from_mem, valid_from_mem);

endmodule

module dcache #(
    parameter SET_BIT_WIDTH = 2,
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter CACHE_LINE_WIDTH = 128
)
(
    input logic clk,
    input logic store,
    input logic [ADDRESS_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] data_in,

    //Mem inputs
    input logic [CACHE_LINE_WIDTH-1:0] fill_data_from_mem,
    input logic fill_data_from_mem_valid,

    output logic req_to_mem,
    output logic req_store_to_mem,
    output logic [ADDRESS_WIDTH-1:0] req_addr_to_mem,
    output logic [DATA_WIDTH-1:0] req_store_data_to_mem,


    output logic hit,
    output logic [DATA_WIDTH-1:0] data_out
);

    localparam CACHE_LINE_BIT_OFFSET = $clog2(CACHE_LINE_WIDTH / DATA_WIDTH);

    logic [ADDRESS_WIDTH - CACHE_LINE_BIT_OFFSET - 1:0] truncated_address_for_cache;
    logic [CACHE_LINE_BIT_OFFSET-1:0] part_in_cacheline;

    assign truncated_address_for_cache = addr[ADDRESS_WIDTH-1:CACHE_LINE_BIT_OFFSET];
    assign part_in_cacheline = addr[CACHE_LINE_BIT_OFFSET-1:0];

    logic write_in_cache_unit;

    logic cache_unit_hit;
    logic [CACHE_LINE_WIDTH-1:0] data_out_cache_unit;


    fully_associative_cache
    #(.SET_BIT_WIDTH(SET_BIT_WIDTH), .INPUT_WIDTH(ADDRESS_WIDTH - CACHE_LINE_BIT_OFFSET), .DATA_WIDTH(CACHE_LINE_WIDTH))
    cacheUnit
    (clk, write_in_cache_unit, truncated_address_for_cache, fill_data_from_mem, ~store, cache_unit_hit, data_out_cache_unit);

    assign write_in_cache_unit = store | (fill_data_from_mem_valid & ~cache_unit_hit);



    assign req_to_mem = ~cache_unit_hit | store;
    assign req_store_to_mem = store;
    assign req_addr_to_mem = addr;
    assign req_store_data_to_mem = data_in;

    assign hit = cache_unit_hit;
    assign data_out = data_out_cache_unit[part_in_cacheline * DATA_WIDTH +: DATA_WIDTH];
endmodule