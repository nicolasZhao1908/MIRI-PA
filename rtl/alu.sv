`include "brisc_pkg.svh"

module alu
  import brisc_pkg::*;
(
    input logic [XLEN-1:0] rs1_data_in,
    input logic [XLEN-1:0] rs2_data_in,
    input logic [XLEN-1:0] imm_in,
    input instr_e instr,
    output logic b_taken,
    output logic [XLEN-1:0] alu_res
);

  always_comb begin
    assign b_taken = 1'b0;
    assign alu_res = '0;
    unique case (instr)
      LW, LB, SW, SB, ADDI: begin
        assign alu_res = rs1_data_in + imm_in;
      end
      ADD: begin
        assign alu_res = rs1_data_in + rs2_data_in;
      end
      BEQ: begin
        assign b_taken = ((rs1_data_in - rs2_data_in) == '0);
      end
      SUB: begin
        assign alu_res = rs1_data_in - rs2_data_in;
      end
      JAL: begin
        assign b_taken = 1'b1;
      end
      XOR: begin
        assign alu_res = rs1_data_in ^ rs2_data_in;
      end
      AND: begin
        assign alu_res = rs1_data_in & rs2_data_in;
      end
      OR: begin
        assign alu_res = rs1_data_in | rs2_data_in;
      end
      MUL: begin
        assign alu_res = rs1_data_in * rs2_data_in;
      end
      default: begin
        // Invalid instructions are handled by the decode stage
      end
    endcase
  end
endmodule
