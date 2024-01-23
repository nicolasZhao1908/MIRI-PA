`include "brisc_pkg.svh"

module cache_top
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,

    input arbiter_grant,
    input cpu_req_t cpu_req,
    input mem_resp_t mem_resp,
    output mem_req_t mem_req,
    output cpu_result_t cpu_res
);

  localparam int unsigned TAGMSB = ADDR_LEN;
  localparam int unsigned TAGLSB = SET_LEN + OFFSET_LEN;

  cache cache_unit (
      .clk(clk),
      .reset(reset),
      .enable(cache_rw),
      .req_set(req_set),
      .req_data(cache_req_data),
      .read_data(cache_read_data)
  );

  cache_set_t cache_read_data;
  logic cache_rw;
  logic [WORD_OFFSET_LEN-1:0] word_offset;
  logic [OFFSET_LEN-1:0] byte_offset;
  cache_set_t cache_req_data;
  logic [SET_LEN-1:0] req_set, req_set_w;

  enum logic [1:0] {
    COMPARE_TAG,
    ALLOCATE,
    WRITE_BACK
  }
      state_n, state_q;


  always_comb begin
    // defaults
    state_n = state_q;
    cpu_res = '{default: 0};
    req_set = cpu_req.addr[SET_LEN+OFFSET_LEN-1:OFFSET_LEN];
    req_set_w = cpu_req.addr[SET_LEN+OFFSET_LEN-1:OFFSET_LEN];
    mem_req = '{
        default: 0,
        addr: {cpu_req.addr[TAGMSB-1:OFFSET_LEN], {OFFSET_LEN{1'b0}}},
        data: cache_read_data.data
    };
    cache_rw = 0;

    word_offset = cpu_req.addr[OFFSET_LEN-1:BYTE_OFFSET_LEN];
    byte_offset = cpu_req.addr[OFFSET_LEN-1:0];

    /*read/write correct word/bytes */
    unique case (cpu_req.size)
      W: begin
        cache_req_data.data[word_offset*WORD_LEN+:WORD_LEN] = cpu_req.data;
        cpu_res.data = cache_read_data[word_offset*WORD_LEN+:WORD_LEN];
      end
      B: begin
        cache_req_data.data[byte_offset*BYTE_LEN+:BYTE_LEN] = cpu_req.data[BYTE_LEN-1:0];
        cpu_res.data = {
          {WORD_LEN - BYTE_LEN{'0}}, cache_read_data[byte_offset*BYTE_LEN+:BYTE_LEN]
        };
      end
    endcase

    // FSM
    case (state_q)
      /*compare_tag state*/
      COMPARE_TAG: begin
        if (cpu_req.valid) begin
          /*cache hit (tag match and cache entry is valid)*/
          if (cpu_req.addr[TAGMSB-1:TAGLSB] == cache_read_data.tag & cache_read_data.valid) begin
            cpu_res.ready = '1;
            /*write hit*/
            if (cpu_req.rw) begin
              cache_rw = '1;
              cache_req_data.tag = cache_read_data.tag;
              cache_req_data.valid = '1;
              cache_req_data.dirty = '1;
            end
          end else begin
            /*cache miss*/

            /*generate memory request on miss*/
            mem_req.valid = '1;

            /*miss with dirty line*/
            if (cache_read_data.dirty) begin
              mem_req.addr = {cache_read_data.tag, req_set_w, {OFFSET_LEN{1'b0}}};
              mem_req.rw = '1;
              /*wait till write is completed*/
              state_n = WRITE_BACK;
            end else begin
              /* miss with clean block */
              /*wait till a new block is allocated*/
              state_n = ALLOCATE;
            end
          end
        end
      end
      /*wait for allocating a new cache line*/
      ALLOCATE: begin
        if (cpu_req.valid) begin
          mem_req.valid = 1;
          /* waiting for fill*/
          if (mem_resp.ready & arbiter_grant &
              mem_resp.addr[ADDR_LEN-1:OFFSET_LEN] == cpu_req.addr[ADDR_LEN-1:OFFSET_LEN]) begin
            state_n = COMPARE_TAG;
            cache_req_data.data = mem_resp.data;
            cache_req_data.tag = cpu_req.addr[TAGMSB-1:TAGLSB];
            cache_req_data.dirty = 0;
            cache_req_data.valid = '1;
            cache_rw = '1;
          end
        end else begin
          state_n = COMPARE_TAG;
        end
      end
      /*wait for writing back dirty cache line*/
      WRITE_BACK: begin
        /*write back is completed*/
        if (cpu_req.valid) begin
          mem_req.valid = 1;
          if (arbiter_grant) begin
            /* once we evict the line we fill with the clean line again*/
            mem_req.valid = '1;
            mem_req.rw = '0;
            mem_req.addr = {cpu_req.addr[TAGMSB-1:BYTE_OFFSET_LEN], {BYTE_OFFSET_LEN{1'b0}}};
            state_n = ALLOCATE;
          end
        end else begin
          state_n = COMPARE_TAG;
        end
      end
      default: begin
        /* NO reachable*/
      end
    endcase
  end

  always_ff @(posedge (clk)) begin
    if (reset) begin
      state_q <= COMPARE_TAG;
    end else begin
      state_q <= state_n;
    end
  end
endmodule
