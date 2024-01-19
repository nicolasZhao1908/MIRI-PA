`include "brisc_pkg.svh"

module arbiter
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,

    input logic mem_req_1,
    input logic mem_write_1,
    input logic [ADDRESS_WIDTH-1:0] mem_addr_1,
    input logic [CACHE_LINE_WIDTH-1:0] mem_data_1,

    input logic mem_req_2,
    input logic mem_write_2,
    input logic [ADDRESS_WIDTH-1:0] mem_addr_2,
    input logic [CACHE_LINE_WIDTH-1:0] mem_data_2,

    output logic grant_1,
    output logic grant_2,

    output logic mem_req,
    output logic mem_write,
    output logic [ADDRESS_WIDTH-1:0] mem_addr,
    output logic [CACHE_LINE_WIDTH-1:0] mem_data
);
  enum logic [1:0] {
    IDLE,
    GRANT_ICACHE,
    GRANT_DCACHE
  }
      state_q, state_n;

  always_comb begin
    grant_2 = 0;
    grant_1 = 0;
    unique case (state_q)
      IDLE: begin
        if (mem_req_1) begin
          state_n   = GRANT_DCACHE;
          mem_req   = 1;
          mem_write = mem_write_1;
          mem_addr  = mem_addr_1;
          mem_data  = mem_data_1;
        end else if (mem_req_2) begin
          state_n   = GRANT_ICACHE;
          mem_req   = 1;
          mem_write = mem_write_2;
          mem_addr  = mem_addr_2;
          mem_data  = mem_data_2;
        end
      end
      GRANT_ICACHE: begin
        if (~mem_req_2) begin
          mem_req = 0;
          state_n = IDLE;
        end
        grant_2 = 1;
      end
      GRANT_DCACHE: begin
        if (~mem_req_1) begin
          mem_req = 0;
          state_n = IDLE;
        end
        grant_1 = 1;
      end
    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      state_q <= IDLE;
    end else begin
      state_q <= state_n;
    end
  end
  //   logic gr2;
  //   logic ff_out;

  //   //assign grant_1   = grant_1_stableizer_ff_out & gr1;
  //   assign grant_1 = grant_1_stableizer_ff_out;
  //   assign gr2 = mem_req_2 & (ff_out | ~mem_req_1);
  //   //assign grant_2   = grant_2_stableizer_ff_out & gr2;
  //   assign grant_2   = grant_2_stableizer_ff_out;
  //   assign mem_req   = grant_1 | grant_2;

  //   // prioritize grant from instruction cache
  //   assign mem_write = grant_1 ? mem_write_1 : mem_write_2;
  //   assign mem_addr  = grant_1 ? mem_addr_1 : mem_addr_2;
  //   assign mem_data  = grant_1 ? mem_data_1 : mem_data_2;

  //   ff #(
  //       .WIDTH(1)
  //   ) req2_running (
  //       .clk(clk),
  //       .enable(1'b1),
  //       .reset(1'b0),
  //       .inp(gr2),
  //       .out(ff_out)
  //   );


  //   logic grant_1_stableizer_ff_out;
  //   ff #(
  //       .WIDTH(1)
  //   ) stabelizer_ff1 (
  //       .clk(clk),
  //       .enable(1'b1),
  //       .reset(1'b0),
  //       .inp(~(ff_out & mem_req_2) & mem_req_1),
  //       .out(grant_1_stableizer_ff_out)
  //   );

  //   logic grant_2_stableizer_ff_out;
  //   ff #(
  //       .WIDTH(1)
  //   ) stabelizer_ff2 (
  //       .clk(clk),
  //       .enable(1'b1),
  //       .reset(1'b0),
  //       .inp(gr2),
  //       .out(grant_2_stableizer_ff_out)
  //   );

  /* logic grant_1_start_allowed; //This code should work, and would make the arb faster, but for some verilog reason it creates undefined behavior...
    assign grant_1_start_allowed = ~(ff_out & req_2) & req_1;
    logic grant_1_stableizer_ff_out;
    ff clock_stabelizer_ff1 (clk, 1'b1, 1'b0, grant_1_start_allowed, grant_1_stableizer_ff_out);

    logic grant_2_start_allowed;
    assign grant_2_start_allowed = gr2;
    logic grant_2_stableizer_ff_out;
    ff clock_stabelizer_ff2 (clk, 1'b1, 1'b0, grant_2_start_allowed, grant_2_stableizer_ff_out);

    assign grant_1 = (grant_1_stableizer_ff_out & req_1) | (grant_1_start_allowed & ~clk);
    assign grant_2 = (grant_2_stableizer_ff_out & req_2) | (grant_2_start_allowed & ~clk);
    */
endmodule
