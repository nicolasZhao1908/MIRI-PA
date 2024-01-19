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
    result = 0;
    unique case (ctrl)
      ADD: begin
        result = src1 + src2;
      end
      SUB: begin
        result = src1 - src2;
      end
      AND: begin
        result = src1 & src2;
      end
      OR: begin
        result = src1 | src2;
      end
      MUL: begin
        result = src1 * src2;
      end
      default: begin
        // all possible bits for ctrl are covered
      end
    endcase

    assign zero = result == '0;
  end
endmodule
