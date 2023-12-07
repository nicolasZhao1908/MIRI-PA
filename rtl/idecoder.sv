`include "brisc_pkg.svh"

module idecoder
  import brisc_pkg::*;
(
    input logic [ILEN-1:0] instr,
    input itype_e i_type,
    output logic [OPCODE_BITS-1:0] opcode,
    output logic [RegBits-1:0] rs1,
    output logic [RegBits-1:0] rs2,
    output logic [RegBits-1:0] rd,
    output logic [6:0] funct7,
    output logic [2:0] funct3,
    output logic [REG_LEN-1:0] imm,
    output logic i_valid
);

  logic [11:0] i_imm, s_imm;
  logic [19:0] u_imm, j_imm;
  logic [12:1] b_imm;

  localparam integer unsigned RegBits = $clog2(REG_LEN);
  always_comb begin
    opcode = instr[OPCODE_BITS-1:0];
    i_valid = 1'b1;
    i_imm = 12'h000;
    b_imm = 12'h000;
    s_imm = 12'h000;
    rs1 = 5'b0_0000;
    rs2 = 5'b0_0000;
    rd = 5'b0_0000;
    funct3 = 3'b000;
    funct7 = 7'b000_0000;
    imm = 32'h0000_00000;
    unique case (i_type)
      R: begin
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        rd = instr[11:7];
        funct7 = instr[31:25];
        funct3 = instr[14:12];
      end
      I: begin
        i_imm = instr[31:20];
        imm = {{20{i_imm[11]}}, i_imm};
        rs1 = instr[19:15];
        rd = instr[11:7];
        funct3 = instr[14:12];
      end
      S: begin
        s_imm[4:0] = instr[11:7];
        s_imm[11:5] = instr[31:25];
        imm = {{20{s_imm[11]}}, s_imm};
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        funct3 = instr[14:12];
      end
      B: begin
        b_imm[11] = instr[7];
        b_imm[4:1] = instr[11:8];
        b_imm[10:5] = instr[30:25];
        b_imm[12] = instr[31];
        imm = {{19{b_imm[12]}}, b_imm, 1'b0};
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        funct3 = instr[14:12];
      end
      default: i_valid = 1'b0;
    endcase
  end
endmodule
