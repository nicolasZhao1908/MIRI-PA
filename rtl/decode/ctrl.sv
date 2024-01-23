`include "brisc_pkg.svh"

module ctrl
  import brisc_pkg::*;
(
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic [OPCODE_LEN-1:0] opcode,
    output logic reg_write,
    output imm_src_e imm_src,
    output result_src_e result_src,
    output alu_src1_e alu_src1,
    output alu_src2_e alu_src2,
    output alu_ctrl_e alu_ctrl,
    output data_size_e data_size,
    output logic mem_write,
    output logic is_branch,
    output logic is_jump,
    output xcpt_e xcpt
);
  alu_op_e alu_op;
  always_comb begin
    xcpt = NO_XCPT;
    reg_write = 1'b0;
    mem_write = 1'b0;
    is_branch = 1'b0;
    is_jump = 1'b0;
    alu_op = ADD_OP;
    alu_src1 = FROM_RS1;
    alu_src2 = FROM_RS2;
    result_src = FROM_ALU;
    unique case (opcode)
      OPCODE_END: begin
        xcpt = NO_XCPT;
      end
      OPCODE_AUIPC: begin
        reg_write = 1'b1;
        imm_src = U_IMM;
        alu_src1 = FROM_PC;
        alu_src2 = FROM_IMM;
        mem_write = 1'b0;
        result_src = FROM_ALU;
        is_branch = 1'b0;
        is_jump = 1'b0;
        alu_op = ADD_OP;
      end
      OPCODE_LOAD: begin
        reg_write = 1'b1;
        imm_src = I_IMM;
        alu_src2 = FROM_IMM;
        mem_write = 1'b0;
        result_src = FROM_CACHE;
        is_branch = 1'b0;
        alu_op = ADD_OP;
        is_jump = 1'b0;
        unique case (funct3)
          3'b000: begin
            data_size = B;
          end
          3'b010: begin
            data_size = W;
          end
          default: begin
            xcpt = UNDEF_INSTR;
          end
        endcase
      end
      OPCODE_STORE: begin
        reg_write = 1'b0;
        imm_src = S_IMM;
        alu_src2 = FROM_IMM;
        mem_write = 1'b1;
        // result_src = XXX
        is_branch = 1'b0;
        alu_op = ADD_OP;
        is_jump = 1'b0;
        unique case (funct3)
          3'b000: begin
            data_size = B;
          end
          3'b010: begin
            data_size = W;
          end
          default: begin
            xcpt = UNDEF_INSTR;
          end
        endcase
      end
      OPCODE_R: begin
        reg_write = 1'b1;
        mem_write = 1'b0;
        // imm_src = XXX
        alu_src1 = FROM_RS1;
        alu_src2 = FROM_RS2;
        alu_op = Rtype_OP;
        // result_src = XXX
        is_branch = 1'b0;
        is_jump = 1'b0;
      end
      OPCODE_BEQ: begin
        reg_write = 1'b0;
        imm_src = B_IMM;
        alu_src2 = FROM_RS2;
        mem_write = 1'b0;
        result_src = FROM_ALU;
        is_branch = 1'b1;
        alu_op = SUB_OP;
        is_jump = 1'b0;
      end

      OPCODE_IMM: begin
        reg_write = 1'b1;
        imm_src = I_IMM;
        alu_src2 = FROM_IMM;
        mem_write = 1'b0;
        is_branch = 1'b0;
        alu_op = Rtype_OP;
        is_jump = 1'b0;
      end

      OPCODE_JUMP: begin
        reg_write = 1'b0;
        imm_src = J_IMM;
        // alu_src = XXX
        mem_write = 1'b0;
        result_src = FROM_PC_NEXT;
        is_branch = 1'b0;
        // alu_op = XXX
        is_jump = 1'b1;
      end
      default: begin
        xcpt = UNDEF_INSTR;
      end
    endcase
    unique case (alu_op)
      ADD_OP: begin
        alu_ctrl = ADD;
      end
      SUB_OP: begin
        alu_ctrl = SUB;
      end
      Rtype_OP: begin
        case (funct3)
          // ADD, ADDI, SUB, MUL
          3'b000: begin
            alu_ctrl = (funct7[5] & opcode[5]) ? SUB : ADD;
            alu_ctrl = (funct7 == FUNCT7_MUL) ? MUL : alu_ctrl;
          end
          // OR, ORI
          3'b110: begin
            alu_ctrl = OR;
          end
          // AND, ANDI
          3'b111: begin
            alu_ctrl = AND;
          end
          default: begin
            xcpt = UNDEF_INSTR;
          end
        endcase
      end
      default: begin
        xcpt = UNDEF_INSTR;
      end
    endcase
  end

endmodule
