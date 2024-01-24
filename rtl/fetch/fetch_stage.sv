`include "brisc_pkg.svh"

module fetch_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_in,
    input pc_src_e pc_src_in,
    input xcpt_e xcpt_in,
    input logic [ADDR_LEN-1:0] pc_target_in,
    output logic [ILEN-1:0] instr_out,
    output logic [XLEN-1:0] pc_out,
    output logic [XLEN-1:0] pc_plus4_out,

    output logic icache_ready_out,
    input logic arbiter_grant_in,
    output mem_req_t mem_req_out,
    input mem_resp_t mem_resp_in,

    input logic pred_wrong_in,
    input logic [XLEN - 1:0] branch_pc_in,
    output logic pred_taken_out
);

  logic [XLEN-1:0] pc_next;
  cpu_result_t cpu_res;
  cpu_req_t cpu_req;

  // 1 entry BTB
  struct packed {
    logic [XLEN-1:0] pred_pc;
    logic [XLEN-1:0] pred_target;
    logic prediction_valid;
  }
      bp_q, bp_n;

  always_comb begin
    cpu_req.valid = ~pc_src_in;
    cpu_req.rw = 0;
    cpu_req.data = 0;
    cpu_req.addr = pc_out;
    cpu_req.size = W;

    instr_out = cpu_res.data;
    icache_ready_out = cpu_res.ready;

    bp_n = bp_q;
    pred_taken_out = 0;

    if (xcpt_in != NO_XCPT) begin
      pc_next = PC_XCPT;
    end else if (pc_src_in == FROM_A) begin
      pc_next = pc_target_in;
      bp_n.pred_pc = branch_pc_in;
      bp_n.pred_target = pc_target_in;
      bp_n.prediction_valid = 1;
    end else if (bp_q.prediction_valid && bp_q.pred_pc == pc_out) begin  // maybe + 4
      pc_next = bp_q.pred_target;
      pc_plus4_out = bp_q.pred_target + 4;
      pred_taken_out = 1;
    end else begin
      pc_next = pc_out + 4;
    end
    pc_plus4_out = pc_next;

    if (pred_wrong_in) begin
      bp_n.prediction_valid = 1;
    end
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
      bp_q   <= '{default: 0};
    end else if (~stall_in | pc_src_in == FROM_A) begin
      pc_out <= pc_next;
      bp_q   <= bp_n;
    end
  end
endmodule
