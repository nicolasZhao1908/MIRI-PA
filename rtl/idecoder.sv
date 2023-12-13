`include "brisc_pkg.svh"


module idecoder
  import brisc_pkg::*;
(
    input logic [ILEN-1:0] instr,
    output logic [RegBits-1:0] rs1,
    output logic [RegBits-1:0] rs2,
    output logic [RegBits-1:0] rd,
    output logic [XLEN-1:0] imm,
    output instr_e out_instr,
    output logic i_valid
);
  logic [OPCODE_BITS-1:0] opcode;
  logic [6:0] funct7;
  logic [2:0] funct3;
  instr_type_e instr_type;

  localparam int unsigned RegBits = $clog2(XLEN);

  always_comb begin
    assign i_valid = 1'b1;
    assign imm = 32'h0000_00000;
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd = instr[11:7];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];
    assign opcode = instr[OPCODE_BITS-1:0];

    unique case (opcode)
      OPCODE_ALU: begin
        assign instr_type = R;
      end
      OPCODE_LOAD, OPCODE_IMM: begin
        assign instr_type = I;
      end
      OPCODE_STORE: begin
        assign instr_type = S;
      end
      OPCODE_BRANCH: begin
        assign instr_type = B;
      end
      OPCODE_JUMP: begin
        assign instr_type = J;
      end
      default: begin
        i_valid = 0;
      end
    endcase
    unique case (instr_type)
      // SUB, ADD, MUL, AND, OR, XOR
      R: begin
        unique case (funct7)
          // for synthesis this is probably non-ideal...
          FUNCT7_AND & FUNCT7_OR & FUNCT7_ADD & FUNCT7_XOR: begin
            unique case (funct3)
              FUNCT3_ADD: begin
                assign out_instr = ADD;
              end
              FUNCT3_XOR: begin
                assign out_instr = XOR;
              end
              FUNCT3_OR: begin
                assign out_instr = OR;
              end
              FUNCT3_AND: begin
                assign out_instr = AND;
              end
              default: begin
                assign i_valid = 0;
              end
            endcase
          end
          FUNCT7_SUB: begin
            unique case (funct3)
              FUNCT3_SUB: begin
                assign out_instr = SUB;
              end
              default: begin
                assign i_valid = 0;
              end
            endcase
          end
          FUNCT7_MUL: begin
            unique case (funct3)
              FUNCT3_MUL: begin
                assign out_instr = MUL;
              end
              default: begin
                assign i_valid = 0;
              end
            endcase
          end
          default: begin
            assign i_valid = 0;
          end
        endcase
      end
      // LW, LB
      I: begin
        assign imm = {{21{instr[31]}}, instr[30:20]};
        unique case (funct3)
          FUNCT3_LB: begin
            assign out_instr = LB;
          end
          FUNCT3_LW: begin
            assign out_instr = LW;
          end
          default: begin
            assign i_valid = 0;
          end
        endcase
      end
      S: begin
        assign imm = {{21{instr[31]}}, instr[30:25], instr[11:7]};
        unique case (funct3)
          FUNCT3_SB: begin
            assign out_instr = SB;
          end
          FUNCT3_SW: begin
            assign out_instr = SW;
          end
          default: begin
            assign i_valid = 0;
          end
        endcase
      end
      B: begin
        assign imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        unique case (funct3)
          FUNCT3_BEQ: begin
            assign out_instr = BEQ;
          end
          default: begin
            assign i_valid = 0;
          end
        endcase
      end
      J: begin
        assign imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        assign out_instr = JAL;
      end
      default: i_valid = 1'b0;
    endcase
  end
endmodule
