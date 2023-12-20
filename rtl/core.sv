`include "brisc_pkg.svh"
`include "cache/dcache.sv"
`include "utility/ff.sv"

module core
  import brisc_pkg::*;
#(
) (
    input logic clk
);
    //STALL LOGIC
    logic stall_fetch;


    //MEM UTIL
    logic enable_1;
    logic store_1;
    logic word_1;
    logic [ADDRESS_BITS-1:0] addr_1;
    logic [XLEN-1:0] data_in_1;
    logic enable_2;
    logic store_2;
    logic word_2;
    logic [ADDRESS_BITS-1:0] addr_2;
    logic [XLEN-1:0] data_in_2;
    logic hit_1;
    logic [XLEN-1:0] data_out_1;
    logic hit_2;
    logic [XLEN-1:0] data_out_2;


    logic [CACHE_LINE_LEN-1:0] fill_from_mem;
    logic valid_from_mem;
    logic req_store_to_mem_1;
    logic [ADDRESS_BITS-1:0] req_addr_to_mem_1;
    logic [XLEN-1:0] req_store_data_to_mem_1;
    logic req_word_to_mem_1;
    logic [ADDRESS_BITS-1:0] req_addr_to_mem_2;
    logic req_to_mem_arb;
    logic req_store_to_mem_arb;
    logic [ADDRESS_BITS-1:0] req_addr_to_mem_arb;
    logic [XLEN-1:0] req_store_data_to_mem_arb;
    logic req_store_word_to_mem_arb;
    logic req_to_arbiter_1;
    logic req_to_arbiter_2;
    logic grant_from_arbiter_1;
    logic grant_from_arbiter_2;

    //----------------------------------- IFETCH ------------------------------------
    logic [ILEN-1:0] instruction_fetch;

    ifetch_stage fetch (
        .clk(clk),
        .reset(1'b0), //TODO WHEN TO RESET???
        .stall_fetch(stall_fetch),
        .b_taken(), //TODO Fill
        .b_target(), //TODO Fill
        .arbiter_grant(grant_from_arbiter_2),
        .fill_data_from_mem(fill_from_mem),
        .fill_data_from_mem_valid(valid_from_mem),
        .req_addr_to_mem(req_addr_to_mem_2),
        .req_to_arbiter(req_to_arbiter_2),

        .instr(instruction_fetch),
        .stall(stall_fetch)//TODO send nops down
    );

    dcache #(
        .SET_BIT_WIDTH(2),
        .ADDRESS_WIDTH(ADDRESS_BITS),
        .DATA_WIDTH(XLEN),
        .CACHE_LINE_WIDTH(CACHE_LINE_LEN)
    ) dcache_unit_1 (
        .clk(clk),
        .enable(enable_1),
        .store(store_1),
        .addr(addr_1),
        .word(word_1),
        .data_in(data_in_1),
        .arbiter_grant(grant_from_arbiter_1),
        .fill_data_from_mem(fill_from_mem),
        .fill_data_from_mem_valid(valid_from_mem),
        .req_store_to_mem(req_store_to_mem_1),
        .req_addr_to_mem(req_addr_to_mem_1),
        .req_store_data_to_mem(req_store_data_to_mem_1),
        .req_to_arbiter(req_to_arbiter_1),
        .req_word_to_mem(req_word_to_mem_1),
        .hit(hit_1),
        .data_out(data_out_1)
    );
    
    arbiter arb (
        .clk(clk),
        .req_1(req_to_arbiter_1),
        .store_to_mem_1(req_store_to_mem_1),
        .addr_to_mem_1(req_addr_to_mem_1),
        .data_to_mem_1(req_store_data_to_mem_1),
        .store_word_1(req_word_to_mem_1),
        .req_2(req_to_arbiter_2),
        .store_to_mem_2(1'b0),
        .addr_to_mem_2(req_addr_to_mem_2),
        .data_to_mem_2(1'b0),
        .store_word_2(1'b0),
        .grant_1(grant_from_arbiter_1),
        .grant_2(grant_from_arbiter_2),
        .request_to_mem(req_to_mem_arb),
        .store_to_mem(req_store_to_mem_arb),
        .addr_to_mem(req_addr_to_mem_arb),
        .data_to_mem(req_store_data_to_mem_arb),
        .store_word_to_mem(req_store_word_to_mem_arb)
    );
    memory #(
        .FILL_DATA_WIDTH(CACHE_LINE_LEN),
        .ADDRESS_WIDTH(ADDRESS_BITS),
        .STORE_DATA_WIDTH(8)
    ) mem (
        .clk(clk),
        .req(req_to_mem_arb),
        .store(req_store_to_mem_arb),
        .storeWord(req_store_word_to_mem_arb),
        .address(req_addr_to_mem_arb),
        .evict_data(req_store_data_to_mem_arb),
        .fill_data(fill_from_mem),
        .response_valid(valid_from_mem)
    );

endmodule
