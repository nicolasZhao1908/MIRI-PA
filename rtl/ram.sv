`include "brisc_pkg.svh"

module ram
  import brisc_pkg::*;
(
    input logic clk,
    input logic req,
    input logic [31:0] addr,
    output logic resp,
    output logic [31:0] data
);
  logic [31:0] ram[63];
  logic [31:0] ph_addr;
  localparam logic [2:0] DelayCycles = 3'b101;
  localparam integer unsigned DelayBits = $clog2(DelayCycles);
  logic [DelayBits-1:0] resp_delay;
  logic [DelayBits-1:0] req_delay;

  initial begin
    req_delay  = DelayCycles;
    resp_delay = DelayCycles;
    $readmemh("ram.txt", ram);
  end

  always_ff @(posedge clk) begin : request_delay
    if (req && req_delay > 3'b000) begin
      req_delay <= req_delay - 3'b001;
    end
  end
  always_ff @(posedge clk) begin : response_delay
    if (req && req_delay == 3'b000 && resp_delay > 3'b000) begin
      resp_delay <= resp_delay - 3'b001;
    end
  end
  always_ff @(posedge clk) begin : rst_delays
    if (req && req_delay == 3'b000 && resp_delay == 3'b000) begin
      resp_delay <= DelayCycles;
      req_delay  <= DelayCycles;
    end
  end

  assign ph_addr = addr;
  assign data = ram[ph_addr[7:2]];
  assign resp = (req && req_delay == 3'b000 && resp_delay == 3'b000) ? 1'b1 : 1'b0;
endmodule
