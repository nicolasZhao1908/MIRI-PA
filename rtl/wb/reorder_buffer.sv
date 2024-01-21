`include "brisc_pkg.svh"

module reorder_buffer
  import brisc_pkg::*;
#(
    // Think about the longest delay/pipeline
    parameter int unsigned NUM_ENTRIES   = 1 << 4,
    parameter int unsigned NUM_COMMITERS = 3
) (
    input logic clk,
    input logic reset,
    input logic enable,

    input rob_req_t reqs[NUM_COMMITERS],

    // Stall other pipelines when handling/answering one
    output logic waits[NUM_COMMITERS],

    // Can STB flush?
    output logic stb_flush_out,

    output logic commit_out,
    output logic [XLEN-1:0] commit_result_out,
    output logic [REG_BITS-1:0] commit_dest_out,
    output xcpt_e commit_xcpt_out,

    output logic avail_ticket_out,

    input logic fwd_alu_rs1_in,
    input logic fwd_alu_rs2_in,

    input logic fwd_alu_ticket_in,

    output logic fwd_alu_src1_out,
    output logic fwd_alu_src1_ready_out,

    output logic fwd_alu_src2_out,
    output logic fwd_alu_src2_ready_out
);

  struct packed {
    logic valid;
    logic [REG_BITS-1:0] dest;
    logic [XLEN-1:0] result;
    xcpt_e xcpt;
  }
      entries_n[NUM_ENTRIES], entries_q[NUM_ENTRIES];

  // Pointers and counters
  logic [$clog2(NUM_ENTRIES)-1:0] read_ptr_n, read_ptr_q;
  logic [$clog2(NUM_ENTRIES)-1:0] write_ptr_n, write_ptr_q;
  logic [$clog2(NUM_ENTRIES):0] cnt_n, cnt_q;

  enum logic {
    IDLE,
    STORE
  }
      state_q, state_n;

  logic empty;
  logic full;
  int unsigned found_idx;
  rob_req_t expected_req;

  always_comb begin
    /* verilator lint_off WIDTH */

    // Defaults
    entries_n = entries_q;
    write_ptr_n = write_ptr_q;
    read_ptr_n = read_ptr_q;
    cnt_n = cnt_q;
    state_n = state_q;
    avail_ticket_out = read_ptr_q;

    full = entries_q == NUM_ENTRIES;
    empty = entries_q == 0;

    commit_out = entries_q[read_ptr_q].valid;
    commit_result_out = entries_q[read_ptr_q].result;
    commit_dest_out = entries_q[read_ptr_q].dest;
    commit_xcpt_out = entries_q[read_ptr_q].xcpt;

    if (commit_out) begin
      read_ptr_n = read_ptr_q + 1;
      cnt_n = cnt_q - 1;
    end

    fwd_alu_src1_ready_out = 0;
    fwd_alu_src2_ready_out = 0;

    for (found_idx = fwd_alu_ticket_in; found_idx != read_ptr_q; --found_idx) begin
    end

    fwd_alu_src1_ready_out = (entries_q[found_idx].dest == fwd_alu_rs1_in) & entries_q[found_idx].valid;
    fwd_alu_src1_out = entries_q[found_idx].result;
    fwd_alu_src2_ready_out = (entries_q[found_idx].dest == fwd_alu_rs2_in) & entries_q[found_idx].valid;
    fwd_alu_src2_out = entries_q[found_idx].result;
    stb_flush_out = 0;

    expected_req = '{default: 0, ticket: read_ptr_q, xcpt: NO_XCPT};

    for (int i = 0; i < NUM_COMMITERS; ++i) begin
      if (reqs[i].req) begin
        if (reqs[i].ticket != expected_req.ticket) begin
          waits[i] = 1;
        end else begin
          expected_req = reqs;
        end
      end
    end

    if (expected_req.store) begin
      state_n = STORE;
    end else if (expected_req.req) begin
      entries_n[expected_req.ticket].valid = 1;
      entries_n[expected_req.ticket].result = expected_req.result;
      entries_n[expected_req.ticket].dest = expected_req.dest;
      entries_n[expected_req.ticket].xcpt = expected_req.xcpt;
      cnt_n = cnt_q + 1;
      write_ptr_n = write_ptr_q + 1;
    end

    unique case (state_q)
      IDLE: begin
        state_n = IDLE;
      end
      STORE: begin
        state_n = IDLE;
        stb_flush_out = 1;
      end
    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      for (int unsigned i = 0; i < NUM_ENTRIES; ++i) begin
        entries_q[i] <= '0;
      end
      write_ptr_q <= '0;
      state_q <= IDLE;
      read_ptr_q <= '0;
      cnt_q <= '0;
    end else if (enable) begin
      entries_q <= entries_n;
      write_ptr_q <= write_ptr_n;
      read_ptr_q <= read_ptr_n;
      cnt_q <= cnt_n;
      state_q <= state_n;
    end
  end
endmodule
