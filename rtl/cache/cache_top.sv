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

  localparam int unsigned TAGMSB = ADDRESS_WIDTH;
  localparam int unsigned TAGLSB = SET_WIDTH + OFFSET_WIDTH;

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
  cache_set_t cache_req_data;
  logic [SET_WIDTH-1:0] req_set, req_set_w;

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
    req_set = cpu_req.addr[SET_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH];
    req_set_w = cpu_req.addr[SET_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH];
    mem_req = '{
        default: 0,
        addr: {cpu_req.addr[TAGMSB-1:OFFSET_WIDTH], {OFFSET_WIDTH{1'b0}}},
        data: cache_read_data.data
    };
    cache_rw = 0;

    /*read/write correct word/bytes */
    case (cpu_req.addr[3:2])
      2'b00: begin
        cache_req_data.data[31:0] = cpu_req.data;
        cpu_res.data = cache_read_data[31:0];
      end
      2'b01: begin
        cache_req_data.data[63:32] = cpu_req.data;
        cpu_res.data = cache_read_data[63:32];
      end
      2'b10: begin
        cache_req_data.data[95:64] = cpu_req.data;
        cpu_res.data = cache_read_data[95:64];
      end
      2'b11: begin
        cache_req_data.data[127:96] = cpu_req.data;
        cpu_res.data = cache_read_data[127:96];
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
              mem_req.addr = {cache_read_data.tag, req_set_w, {OFFSET_WIDTH{1'b0}}};
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
              mem_resp.addr[ADDRESS_WIDTH-1:OFFSET_WIDTH] == cpu_req.addr[ADDRESS_WIDTH-1:OFFSET_WIDTH]) begin
            state_n = COMPARE_TAG;
            cache_req_data.data = mem_resp.data;
            cache_req_data.tag = cpu_req.addr[TAGMSB-1:TAGLSB];
            cache_req_data.dirty = 0;
            cache_req_data.valid = '1;
            cache_rw = '1;
          end
          if (cpu_req.rw & arbiter_grant) begin
            state_n = COMPARE_TAG;
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
            mem_req.addr = {cpu_req.addr[TAGMSB-1:BYTE_OFFSET_WIDTH], {BYTE_OFFSET_WIDTH{1'b0}}};
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
