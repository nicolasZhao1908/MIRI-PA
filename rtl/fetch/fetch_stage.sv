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

    output logic icache_ready_out,
    input logic arbiter_grant_in,
    output mem_req_t mem_req_out,
    input mem_resp_t mem_resp_in
);

  logic [XLEN-1:0] pc_next;
  cpu_result_t cpu_res;
  cpu_req_t cpu_req;

  always_comb begin
    cpu_req.valid = ~pc_src_in;
    cpu_req.rw = 0;
    cpu_req.addr = pc_out;
    cpu_req.size = W;

    instr_out = cpu_res.data;
    icache_ready_out = cpu_res.ready;

    pc_next = xcpt_in ? PC_XCPT : ((pc_src_in == FROM_A) ? pc_target_in : pc_out + 4);
    pc_plus4_out = pc_next;
  end

  // We use cache_top as the icache too since
  // it has the interface with memory and arbiter
  cache_top icache (
      .clk(clk),
      .reset(reset),
      .arbiter_grant(arbiter_grant_in),
      .cpu_req(cpu_req),
      .cpu_res(cpu_res),
      .mem_req(mem_req_out),
      .mem_resp(mem_resp_in)
  );

  always_ff @(posedge clk) begin
    if (reset) begin
      pc_out <= PC_BOOT;
    end else if (~stall_in | pc_src_in) begin
      pc_out <= pc_next;
    end
  end
endmodule
