`include "brisc_pkg.svh"

module alu
  import brisc_pkg::*;
(
    input logic [XLEN-1:0] src1,
    input logic [XLEN-1:0] src2,
    input alu_ctrl_e ctrl,
    output logic zero,
    output logic [XLEN-1:0] result
);

  always_comb begin
    unique case (ctrl)
      ADD: begin
        assign result = src1 + src2;
      end
      SUB: begin
        assign result = src1 - src2;
      end
      AND: begin
        assign result = src1 & src2;
      end
      OR: begin
        assign result = src1 | src2;
      end
      default: begin
        // all possible bits for ctrl are covered
      end
    endcase

    assign zero = result == '0;
  end
endmodule
