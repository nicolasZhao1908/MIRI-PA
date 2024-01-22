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
    input mem_resp_t mem_resp_in,

    input logic invalidate_branch_predictor,
    input logic [XLEN - 1:0] jump_taken_from_address,
    output logic branch_prediction
);

  logic [XLEN-1:0] pc_next;
  cpu_result_t cpu_res;
  cpu_req_t cpu_req;

  //Branch predictor
  logic [XLEN-1:0] prediction_address_q;
  logic [XLEN-1:0] jump_to_q;
  logic prediction_valid_q;

  logic [XLEN-1:0] prediction_address_n;
  logic [XLEN-1:0] jump_to_n;
  logic prediction_valid_n;

  always_comb begin
    cpu_req.valid = ~pc_src_in & ~invalidate_branch_predictor;
    cpu_req.rw = 0;
    cpu_req.addr = pc_out;
    cpu_req.size = W;

    instr_out = cpu_res.data;
    icache_ready_out = cpu_res.ready;

    //pc_next = xcpt_in ? PC_XCPT : ((pc_src_in == FROM_A) ? pc_target_in : pc_out + 4);
    prediction_address_n = prediction_address_q;
    prediction_valid_n = prediction_valid_q;
    jump_to_n = jump_to_q;

    branch_prediction = 0;

    if (xcpt_in) begin
      pc_next = PC_XCPT;
    end else if(pc_src_in == FROM_A) begin
      pc_next = pc_target_in;
      prediction_address_n = jump_taken_from_address;
      jump_to_n = pc_target_in;
      prediction_valid_n = 1;
    end else if (prediction_valid_q && prediction_address_q == pc_out) begin // maybe + 4
      pc_next = jump_to_q;
      pc_plus4_out = jump_to_q + 4;
      branch_prediction = 1;
    end else begin
      pc_next = pc_out + 4;
    end
    pc_plus4_out = pc_next;

    if (invalidate_branch_predictor) begin
      prediction_valid_n = 1;
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
    end else if (~stall_in | pc_src_in) begin
      pc_out <= pc_next;
      prediction_address_q <= prediction_address_n;
      prediction_valid_q <= prediction_valid_n;
      jump_to_q <= jump_to_n;
    end

    // if(invalidate_branch_predictor) begin
    //   prediction_valid <= 0;
    // end
  end
endmodule
