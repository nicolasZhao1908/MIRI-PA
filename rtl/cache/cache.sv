`include "brisc_pkg.svh"

module cache
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic [1:0] req_set,
    input cache_set_t req_data,
    output cache_set_t read_data
);
  cache_set_t cache_sets_q[NUM_CACHE_LINES], cache_sets_n[NUM_CACHE_LINES];

  always_comb begin
    cache_sets_n = cache_sets_q;
    cache_sets_n[req_set] = req_data;
    read_data = cache_sets_q[req_set];
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      for (int unsigned i = 0; i < NUM_CACHE_LINES; ++i) begin
        cache_sets_q[i] <= '0;
      end
    end else if (enable) begin
      cache_sets_q <= cache_sets_n;
    end
  end
endmodule
