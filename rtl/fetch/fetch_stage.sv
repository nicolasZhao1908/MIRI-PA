`include "brisc_pkg.svh"

module fetch_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_in,
    input pc_src_e pc_src_in,
    input logic xcpt_in,
    input logic [ADDRESS_WIDTH-1:0] pc_target_in,
    output logic [ILEN-1:0] instr_out,
    output logic [XLEN-1:0] pc_out,
    output logic [XLEN-1:0] pc_plus4_out,

    // Cache
    input logic arbiter_grant_in,
    output logic mem_req_out,
    output logic [ADDRESS_WIDTH-1:0] mem_req_addr_out,

    // Memory
    input logic mem_resp_in,
    input logic [CACHE_LINE_WIDTH-1:0] mem_resp_data_in,
    input logic [ADDRESS_WIDTH-1:0] mem_resp_addr_in
);

  logic [XLEN-1:0] pc_next;

  assign pc_next = xcpt_in ? PC_XCPT : ((pc_src_in == FROM_A) ? pc_target_in : pc_out + 4);
  assign pc_plus4_out = pc_next;

  always_ff @(posedge clk) begin
    if (reset) begin
      pc_out <= PC_BOOT;
    end else if (~stall_in | xcpt_in | pc_src_in) begin
      pc_out <= pc_next;
    end
  end

  // We use cache_top as the icache too since
  // it has the interface with memory and arbiter
  cache_top icache (
      .clk  (clk),
      .reset(reset),
      .addr (pc_out),

      // We always load a word
      .data_size(W),
      .is_load  (~reset),
      .is_store (0),
      .read_data(instr_out),

      // Arbiter
      .arbiter_grant(arbiter_grant_in),
      .mem_req(mem_req_out),
      .mem_req_addr(mem_req_addr_out),
      .mem_req_data(),
      .mem_req_write(),

      // Memory
      .mem_resp(mem_resp_in),
      .mem_resp_data(mem_resp_data_in),
      .mem_resp_addr(mem_resp_addr_in),

      // STB
      // read_valid needs to be 0 so we make a request only in cache miss
      .stb_read_valid(1'b0),
      .stb_write_data(),
      .stb_write_addr(),
      .stb_write(1'b0),
      .stb_write_size()
  );

endmodule
