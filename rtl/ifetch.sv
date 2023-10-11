
`include "brisc_pkg.svh"

module ifetch
  import brisc_pkg::*;
#(

) (
    input logic clk,
    input logic rst,
    input logic b_taken,
    input logic [ADDRESS_BITS-1:0] b_addr,
    input logic enable,
    output logic [REG_LEN-1:0] pc_next
);

  logic [REG_LEN-1:0] pc_curr = PC_BOOT;

  always_ff @(posedge clk) begin
    if (enable) begin
      pc_curr <= b_taken ? b_addr : pc_curr + 4;
      pc_next <= b_taken ? b_addr : pc_curr + 4;
    end
  end

endmodule
