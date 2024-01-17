`include "brisc_pkg.svh"

module fetch_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_in,
    input pc_src_e pc_src_in,
    input xcpt_e xcpt_in,
    input logic [ADDRESS_WIDTH-1:0] pc_target_in,
    output logic [ILEN-1:0] instr_out,
    output logic [XLEN-1:0] pc_out,
    output logic [XLEN-1:0] pc_plus4_out,

    // CACHE
    input logic arbiter_grant,
    output logic arbiter_req,
    output logic [ADDRESS_WIDTH-1:0] mem_req_addr,
    output logic [CACHE_LINE_WIDTH-1:0] mem_req_data,
    output logic mem_req_write,

    // MEMORY
    input logic mem_resp,
    input logic [CACHE_LINE_WIDTH-1:0] mem_resp_data,
    input logic [ADDRESS_WIDTH-1:0] mem_resp_addr
);

  logic [XLEN-1:0] pc_next;
  logic cache_miss;
  logic stall_pc;

  assign pc_next = (xcpt_in != NO_XCPT) ? PC_XCPT :
                  ((pc_src_in == FROM_A) ? pc_target_in : pc_out + 4);
  assign pc_plus4_out = pc_next;
  assign stall_pc = (stall_in | cache_miss) & ~mem_resp;

  always_ff @(posedge clk) begin
    if (reset) begin
      pc_out <= PC_BOOT;
    end else if (~stall_pc) begin
      pc_out <= pc_next;
    end
  end

  // We use cache_top as the icache too since
  // it has the interface with memory and arbiter

  cache_top icache (
      // PIPELINE
      .clk(clk),
      .reset(1'b0),
      .enable(1'b1),
      .is_load(1'b0),
      .addr(pc_out),
      .data_size(W),
      .miss(cache_miss),
      .read_data(instr_out),

      // ARBITER
      .arbiter_grant(arbiter_grant),
      .arbiter_req  (arbiter_req),
      .mem_req_addr (mem_req_addr),
      .mem_req_data (mem_req_data),
      .mem_req_write(mem_req_write),

      // MEMORY
      .mem_resp(mem_resp),
      .mem_resp_data(mem_resp_data),
      .mem_resp_addr(mem_resp_addr),

      // SB
      .stb_write_data(),
      .stb_write_addr(),
      .stb_read_valid(),
      .stb_write(),
      .stb_write_size()
  );

endmodule
