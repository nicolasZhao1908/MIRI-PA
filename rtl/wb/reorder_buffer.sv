`include "brisc_pkg.svh"

module reorder_buffer
  import brisc_pkg::*;
#(
    // Think about the longest delay/pipeline
    parameter int unsigned NUM_ENTRIES = ROB_NUM_ENTRIES,
    parameter int unsigned NUM_REQS = ROB_NUM_REQS
) (
    input logic clk,
    input logic reset,
    input logic enable,

    // Request ticket
    input logic req_ticket_in,
    input logic [REGMSB-1:0] req_dest_in,
    output logic [ROB_TICKET_LEN-1:0] resp_ticket_out,

    // Request to store in ROB
    input rob_req_t reqs_in[NUM_REQS],
    // Stall other pipelines when handling/answering one
    output logic waits_out[NUM_REQS],

    // Result to commit in regfile
    output logic commit_out,
    output logic commit_reg_rw_out,
    output logic commit_mem_rw_out,
    output logic [XLEN-1:0] commit_result_out,
    output logic [REGMSB-1:0] commit_dest_out,
    output xcpt_e commit_xcpt_out,

    // Instruction in ALU stage checks if any of its src operands
    // is in ROB
    input logic [REGMSB-1:0] fwd_alu_rs1_in,
    input logic [REGMSB-1:0] fwd_alu_rs2_in,
    input logic [$clog2(ROB_NUM_ENTRIES)-1:0] fwd_alu_ticket_in,
    output logic [XLEN-1:0] fwd_alu_src1_out,
    output logic fwd_alu_src1_ready_out,
    output logic [XLEN-1:0] fwd_alu_src2_out,
    output logic fwd_alu_src2_ready_out
);

  struct packed {
    logic ready;
    logic mem_rw;
    logic reg_rw;
    logic [REGMSB-1:0] dest;
    logic [XLEN-1:0] result;
    xcpt_e xcpt;
  }
      entries_n[NUM_ENTRIES], entries_q[NUM_ENTRIES];

  logic waits[NUM_REQS];
  // Pointers and counters
  logic [$clog2(NUM_ENTRIES)-1:0] read_ptr_n, read_ptr_q;
  logic [$clog2(NUM_ENTRIES)-1:0] write_ptr_n, write_ptr_q;
  logic [$clog2(NUM_ENTRIES):0] cnt_n, cnt_q;

  logic fwd1_ready, fwd2_ready;
  rob_req_t granted_req;
  int unsigned fwd1_idx, fwd2_idx, commit_idx;
  enum logic {
    IDLE,
    GRANT
  }
      state_q, state_n;

  always_comb begin

    // Defaults
    entries_n = entries_q;
    write_ptr_n = write_ptr_q;
    read_ptr_n = read_ptr_q;
    cnt_n = cnt_q;
    state_n = state_q;

    resp_ticket_out = write_ptr_q;

    // Give tickets
    if (req_ticket_in) begin
      entries_n[write_ptr_q].ready = 0;
      entries_n[write_ptr_q].dest = req_dest_in;
      cnt_n = cnt_q + 1;
      write_ptr_n = write_ptr_q + 1;
    end

    commit_out = entries_q[read_ptr_q].ready;
    commit_result_out = entries_q[read_ptr_q].result;
    commit_dest_out = entries_q[read_ptr_q].dest;
    commit_xcpt_out = entries_q[read_ptr_q].xcpt;
    commit_reg_rw_out = entries_q[read_ptr_q].reg_rw;
    commit_mem_rw_out = entries_q[read_ptr_q].mem_rw;

    // Forwarding to ALU logic
    fwd_alu_src1_ready_out = 0;
    fwd_alu_src2_ready_out = 0;

    fwd1_ready = 0;
    fwd2_ready = 0;

    /* verilator lint_off WIDTH */
    for (fwd1_idx = fwd_alu_ticket_in; fwd1_idx != read_ptr_q; --fwd1_idx) begin
      if (entries_q[fwd1_idx].dest == fwd_alu_rs1_in) begin
        fwd1_ready = 1;
        break;
      end
    end

    for (fwd2_idx = fwd_alu_ticket_in; fwd2_idx != read_ptr_q; --fwd2_idx) begin
      if (entries_q[fwd2_idx].dest == fwd_alu_rs2_in) begin
        fwd2_ready = 1;
        break;
      end
    end


    fwd_alu_src1_ready_out = entries_q[fwd1_idx].ready & fwd1_ready;
    fwd_alu_src2_ready_out = entries_q[fwd2_idx].ready & fwd2_ready;

    fwd_alu_src1_out = entries_q[fwd1_idx].result;
    fwd_alu_src2_out = entries_q[fwd2_idx].result;


    granted_req = '{default: 0, ticket: read_ptr_q, xcpt: NO_XCPT};

    waits = waits_out;

    for (int unsigned i = 0; i < NUM_REQS; ++i) begin
      waits[i] = 0;
    end

    // When there is more than 1 req at the same time, grant the
    // one which has more priority
    //
    // Priority: reqs[0] > reqs[1] > ... > reqs[NUM_REQS-1]
    for (int i = 0; i < NUM_REQS; ++i) begin
      if (reqs_in[i].valid) begin
        granted_req = reqs_in[i];
        continue;
      end
      if (granted_req.valid & reqs_in[i].valid) begin
        waits[i] = 1;
      end
    end

    if (granted_req.valid) begin
      entries_n[granted_req.ticket].ready  = 1;
      entries_n[granted_req.ticket].result = granted_req.result;
      entries_n[granted_req.ticket].dest   = granted_req.dest;
      entries_n[granted_req.ticket].xcpt   = granted_req.xcpt;
      entries_n[granted_req.ticket].reg_rw = granted_req.reg_rw;
      entries_n[granted_req.ticket].mem_rw = granted_req.mem_rw;
    end

    // Commit the head
    if (entries_q[read_ptr_q].ready) begin
      // In order to commit a store into cache it needs to receive the request from STB
      if (entries_q[read_ptr_q].mem_rw) begin
        entries_n[read_ptr_q].ready = 0;
        read_ptr_n = read_ptr_q + 1;
        cnt_n = cnt_q - 1;
      end else if (~entries_q[read_ptr_q].mem_rw) begin
        entries_n[read_ptr_q].ready = 0;
        read_ptr_n = read_ptr_q + 1;
        cnt_n = cnt_q - 1;
      end
    end

  end

  always_ff @(posedge clk) begin
    if (reset) begin
      for (int unsigned i = 0; i < NUM_ENTRIES; ++i) begin
        entries_q[i] <= '0;
        waits_out[i] <= 0;
      end
      write_ptr_q <= '0;
      read_ptr_q <= '0;
      cnt_q <= '0;
    end else if (enable) begin
      entries_q <= entries_n;
      write_ptr_q <= write_ptr_n;
      read_ptr_q <= read_ptr_n;
      cnt_q <= cnt_n;
      waits_out <= waits;
    end
  end
endmodule
