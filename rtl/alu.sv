`include "brisc_pkg.svh"

module alu
  import brisc_pkg::*;
#(
    parameter int unsigned WIDTH = XLEN
) (
    input logic [WIDTH-1:0] src1,
    input logic [WIDTH-1:0] src2,
    input instr_e instr,
    output logic b_taken,
    output logic [WIDTH-1:0] alu_res
);

  always_comb begin
    assign b_taken =  1'b0;
    assign alu_res = '0;
    unique case (instr)
      LW, LB, ADDI, SW, SB, ADD, JAL: begin
        assign alu_res = src1 + src2;
      end
      BEQ, SUB: begin
        assign alu_res = src1 - src2;
        assign b_taken = alu_res == '0;
      end
      XOR: begin
        assign alu_res = src1 ^ src2;
      end
      AND: begin
        assign alu_res = src1 & src2;
      end
      OR: begin
        assign alu_res = src1 | src2;
      end
      MUL: begin
        assign alu_res = src1 * src2;
      end
      default: begin
        // Invalid instructions are handled by the decode stage
      end
    endcase
  end
endmodule
