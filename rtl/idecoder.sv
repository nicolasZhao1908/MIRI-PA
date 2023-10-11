`include "brisc_pkg.svh"

module idecoder
  import brisc_pkg::*;
#(
    parameter int unsigned REG_BITS = $clog2(REG_LEN)
) (
    input logic [ILEN-1:0] instr,
    input itype_e i_type,
    output logic [OPCODE_BITS-1:0] opcode,
    output logic [REG_BITS-1:0] rs1,
    output logic [REG_BITS-1:0] rs2,
    output logic [REG_BITS-1:0] rd,
    output logic [6:0] funct7,
    output logic [2:0] funct3,
    output logic [11:0] i_imm,
    output logic [11:0] s_imm,
    output logic [12:1] b_imm,
    output logic [19:0] u_imm,
    output logic [19:0] j_imm,
    output logic i_valid
);

  initial begin
    assign i_valid = 1'b1;
  end

  always_comb begin
    opcode = instr[OPCODE_BITS-1:0];
    case (i_type)
      R: begin
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        rd = instr[11:7];
        funct7 = instr[31:25];
        funct3 = instr[14:12];
      end
      I: begin
        i_imm = instr[31:20];
        rs1 = instr[19:15];
        rd = instr[11:7];
        funct3 = instr[14:12];
      end
      S: begin
        s_imm[4:0] = instr[11:7];
        s_imm[11:5] = instr[31:25];
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        funct3 = instr[14:12];
      end
      B: begin
        b_imm[11] = instr[7];
        b_imm[4:1] = instr[11:8];
        b_imm[10:5] = instr[30:25];
        b_imm[12] = instr[31];
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        funct3 = instr[14:12];
      end
      default: i_valid = 1'b0;
    endcase
  end


endmodule
