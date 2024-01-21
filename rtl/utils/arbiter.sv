`include "brisc_pkg.svh"

module arbiter
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,

    input mem_req_t ireq,
    input mem_req_t dreq,

    output logic igrant,
    output logic dgrant,

    output mem_req_t mem_req
);
  enum logic [1:0] {
    IDLE,
    GRANT_ICACHE,
    GRANT_DCACHE
  }
      state_q, state_n;

  always_comb begin
    dgrant = 0;
    igrant = 0;
    unique case (state_q)
      IDLE: begin
        if (dreq.valid) begin
          state_n = GRANT_DCACHE;
          mem_req = dreq;
        end else if (ireq.valid) begin
          state_n = GRANT_ICACHE;
          mem_req = ireq;
        end
      end
      GRANT_ICACHE: begin
        mem_req = ireq;
        if (~ireq.valid) begin
          mem_req.valid = 0;
          state_n = IDLE;
        end
        igrant = 1'b1;
      end
      GRANT_DCACHE: begin
        mem_req = dreq;
        if (~dreq.valid) begin
          mem_req.valid = 0;
          state_n = IDLE;
        end
        dgrant = 1;
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

endmodule

// module arbiter
//   import brisc_pkg::*;
// #(
//     parameter NUM_RQ = 2  // Number of requestors
// ) (
//     input logic clk,
//     input logic reset,

//     // priority is based on position in reqs
//     // reqs[0] > reqs[1] > ... > reqs[NUM_RQ]
//     input mem_req_t reqs[NUM_RQ],
//     output logic grants[NUM_RQ],

//     output mem_req_t mem_req
// );
//   logic [NUM_RQ:0] states_q, states_n;

//   always_comb begin
//     states_n = states_q;
//     mem_req  = '{default: 0};
//     // state[0] -> idle
//     // state[n] -> granting request n 
//     if (states_q[0]) begin
//       for (int unsigned i = 0; i < NUM_RQ; ++i) begin
//         grants[i] = 0;
//         if (reqs[i].valid) begin
//           mem_req.valid = 1;
//           states_n[i+1] = 1;
//           states_n[0]   = 0;
//           break;
//         end
//       end
//     end else begin
//       for (int unsigned i = 0; i < NUM_RQ; ++i) begin
//         grants[i] = 0;
//         if (states_q[i+1]) begin
//           mem_req.addr = reqs[i].addr;
//           mem_req.rw   = reqs[i].rw;
//           mem_req.data = reqs[i].data;
//           if (~reqs[i].valid) begin
//             mem_req.valid = 0;
//             states_n[0]   = 1;
//             states_n[i]   = 0;
//           end
//           grants[i] = 1'b1;
//           break;
//         end
//       end
//     end
//   end

//   always_ff @(posedge clk) begin
//     if (reset) begin
//       for (int unsigned i = 0; i < NUM_RQ; ++i) begin
//         states_q[i+1] <= 0;
//       end
//       states_q[0] <= 1;
//     end else begin
//       states_q <= states_n;
//     end
//   end
// endmodule
