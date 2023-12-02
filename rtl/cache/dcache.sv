`include "utility/fully_associative_cache.sv"
`include "utility/memory.sv"
`include "cache/arbiter.sv"

module two_caches_arbiter_testonly #(
    parameter SET_BIT_WIDTH = 2,
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter CACHE_LINE_WIDTH = 128
) (
    input logic clk,
    input logic enable_1,
    input logic store_1,
    input logic [ADDRESS_WIDTH-1:0] addr_1,
    input logic [DATA_WIDTH-1:0] data_in_1,

    input logic enable_2,
    input logic store_2,
    input logic [ADDRESS_WIDTH-1:0] addr_2,
    input logic [DATA_WIDTH-1:0] data_in_2,

    output logic hit_1,
    output logic [DATA_WIDTH-1:0] data_out_1,

    output logic hit_2,
    output logic [DATA_WIDTH-1:0] data_out_2

    /*,output logic [3:0] rg_out
    ,output logic [1:0] mem_resp
    ,output logic [DATA_WIDTH-1:0] arb2mem
    ,output logic [CACHE_LINE_WIDTH-1:0] mem2arb
    ,output logic [ADDRESS_WIDTH-1:0] arb2memAddr
    ,output logic arb2memStr
    ,output logic [0:0] enables_out [128]
    ,output logic strAndReq
    ,output logic [6:0] controlAddr
    ,output logic [128:0] mem_oi
    ,output logic [32-1:0] data_out_out [128]
    ,output logic [32-1:0] evict_data_out*/
);

    logic [CACHE_LINE_WIDTH-1:0] fill_from_mem;
    logic valid_from_mem;


    logic req_store_to_mem_1;
    logic [ADDRESS_WIDTH-1:0] req_addr_to_mem_1;
    logic [DATA_WIDTH-1:0] req_store_data_to_mem_1;

    logic req_store_to_mem_2;
    logic [ADDRESS_WIDTH-1:0] req_addr_to_mem_2;
    logic [DATA_WIDTH-1:0] req_store_data_to_mem_2;


    logic req_to_mem_arb;
    logic req_store_to_mem_arb;
    logic [ADDRESS_WIDTH-1:0] req_addr_to_mem_arb;
    logic [DATA_WIDTH-1:0] req_store_data_to_mem_arb;


    logic req_to_arbiter_1;
    logic req_to_arbiter_2;
    logic grand_from_arbiter_1;
    logic grand_from_arbiter_2;

    dcache
    #(.SET_BIT_WIDTH(SET_BIT_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH), .CACHE_LINE_WIDTH(CACHE_LINE_WIDTH))
    dcache_unit_1
    (clk, enable_1, store_1, addr_1, data_in_1, grand_from_arbiter_1, fill_from_mem, valid_from_mem,
    req_store_to_mem_1, req_addr_to_mem_1, req_store_data_to_mem_1, req_to_arbiter_1, hit_1, data_out_1);

    dcache
    #(.SET_BIT_WIDTH(SET_BIT_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH), .CACHE_LINE_WIDTH(CACHE_LINE_WIDTH))
    dcache_unit_2
    (clk, enable_2, store_2, addr_2, data_in_2, grand_from_arbiter_2, fill_from_mem, valid_from_mem,
    req_store_to_mem_2, req_addr_to_mem_2, req_store_data_to_mem_2, req_to_arbiter_2, hit_2, data_out_2);

    arbiter arb (clk, req_to_arbiter_1, req_store_to_mem_1, req_addr_to_mem_1, req_store_data_to_mem_1,
                req_to_arbiter_2, req_store_to_mem_2, req_addr_to_mem_2, req_store_data_to_mem_2,
                grand_from_arbiter_1, grand_from_arbiter_2,
                req_to_mem_arb, req_store_to_mem_arb, req_addr_to_mem_arb, req_store_data_to_mem_arb
        );

    memory
    #(.FILL_DATA_WIDTH(CACHE_LINE_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .STORE_DATA_WIDTH(DATA_WIDTH))
    mem
    (clk, req_to_mem_arb, req_store_to_mem_arb, req_addr_to_mem_arb, req_store_data_to_mem_arb, fill_from_mem, valid_from_mem);

    //ADDITIONAL DEBUG STATEMENTS FOR MEM: , enables_out, strAndReq, controlAddr, mem_oi, cabels, data_out_out, evict_data_out
    //DEBUG
    /*
    assign rg_out = {req_to_arbiter_1, grand_from_arbiter_1, req_to_arbiter_2, grand_from_arbiter_2};
    assign mem_resp = {req_to_mem_arb, valid_from_mem};
    assign arb2mem = req_store_data_to_mem_arb;
    assign mem2arb = fill_from_mem;
    assign arb2memAddr = req_addr_to_mem_arb;
    assign arb2memStr = req_store_to_mem_arb; */
endmodule

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

    logic arbiter_grand;

    dcache
    #(.SET_BIT_WIDTH(SET_BIT_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH), .CACHE_LINE_WIDTH(CACHE_LINE_WIDTH))
    dcache_unit
    (clk, 1'b1, store, addr, data_in, arbiter_grand, fill_from_mem, valid_from_mem,
    req_store_to_mem, req_addr_to_mem, req_store_data_to_mem, arbiter_grand, hit, data_out);

    assign req_to_mem = arbiter_grant;
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
    input logic enable,
    input logic store,
    input logic [ADDRESS_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] data_in,

    //Arbiter input
    input logic arbiter_grant,

    //Mem inputs
    input logic [CACHE_LINE_WIDTH-1:0] fill_data_from_mem,
    input logic fill_data_from_mem_valid,

    //Mem outputs
    output logic req_store_to_mem,
    output logic [ADDRESS_WIDTH-1:0] req_addr_to_mem,
    output logic [DATA_WIDTH-1:0] req_store_data_to_mem,

    //Arbiter outputs
    output logic req_to_arbiter,

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

    assign write_in_cache_unit = store | (arbiter_grant & fill_data_from_mem_valid & ~cache_unit_hit);



    assign req_to_arbiter = (~cache_unit_hit | store) & enable;

    assign req_store_to_mem = store;
    assign req_addr_to_mem = addr;
    assign req_store_data_to_mem = data_in;

    //logic delay_arbiter_grant_store;
    //...

    assign hit = (cache_unit_hit & ~store) | (store & arbiter_grant);
    assign data_out = data_out_cache_unit[part_in_cacheline * DATA_WIDTH +: DATA_WIDTH];
endmodule