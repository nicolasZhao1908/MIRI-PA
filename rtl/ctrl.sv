`include "brisc_pkg.svh"

module ctrl
  import brisc_pkg::*;
(
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic [OPCODE_BITS-1:0] opcode,
    output logic reg_write,
    output imm_src_e imm_src,
    output result_src_e result_src,
    output alu_src_e alu_src,
    output alu_ctrl_e alu_ctrl,
    output mem_op_size_e mem_op_size,
    output logic mem_write,
    output logic is_branch,
    output logic is_jump,
    output logic xcpt
);
  alu_op_e alu_op;
  always_comb begin
    assign xcpt = 1'b0;
    assign reg_write = 1'b0;
    assign mem_write = 1'b0;
    assign is_branch = 1'b0;
    assign is_jump = 1'b0;
    assign alu_op = ADD_OP;
    unique case (opcode)
      OPCODE_LOAD: begin
        assign reg_write = 1'b1;
        assign imm_src = I_IMM;
        assign alu_src = FROM_IMM;
        assign mem_write = 1'b0;
        assign result_src = FROM_CACHE;
        assign is_branch = 1'b0;
        assign alu_op = ADD_OP;
        assign is_jump = 1'b0;
        unique case(funct3)
          3'b000: begin
            assign mem_op_size = B;
          end
          3'b010: begin
            assign mem_op_size = W;
          end
          default:
          begin
            assign xcpt = 1;
          end
        endcase
      end
      OPCODE_STORE: begin
        assign reg_write = 1'b0;
        assign imm_src = S_IMM;
        assign alu_src = FROM_IMM;
        assign mem_write = 1'b1;
        // result_src = XXX
        assign is_branch = 1'b0;
        assign alu_op = ADD_OP;
        assign is_jump = 1'b0;
        unique case(funct3)
          3'b000: begin
            assign mem_op_size = B;
          end
          3'b010: begin
            assign mem_op_size = W;
          end
          default:
          begin
            assign xcpt = 1;
          end
        endcase
      end
      OPCODE_R: begin
        assign reg_write = 1'b1;
        // imm_src = XXX
        assign alu_src = FROM_RS2;
        assign mem_write = 1'b0;
        // result_src = XXX
        assign is_branch = 1'b0;
        assign alu_op = Rtype_OP;
        assign is_jump = 1'b0;
      end
      OPCODE_BEQ: begin
        assign reg_write = 1'b0;
        assign imm_src = B_IMM;
        assign alu_src = FROM_RS2;
        assign mem_write = 1'b0;
        // result_src = XXX
        assign is_branch = 1'b1;
        assign alu_op = SUB_OP;
        assign is_jump = 1'b0;
      end

      OPCODE_IMM: begin
        assign reg_write = 1'b1;
        assign imm_src = I_IMM;
        assign alu_src = FROM_RS2;
        assign mem_write = 1'b0;
        assign is_branch = 1'b0;
        assign alu_op = SUB_OP;
        assign is_jump = 1'b0;
      end

      OPCODE_JUMP: begin
        assign reg_write = 1'b1;
        assign imm_src = J_IMM;
        // alu_src = XXX
        assign mem_write = 1'b0;
        assign result_src = FROM_PC_NEXT;
        assign is_branch = 1'b0;
        // alu_op = XXX
        assign is_jump = 1'b1;
      end
      default: begin
        xcpt = 1;
      end
    endcase
    unique case (alu_op)
      ADD_OP: begin
        assign alu_ctrl = ADD;
      end
      SUB_OP: begin
        assign alu_ctrl = SUB;
      end
      Rtype_OP: begin
        unique case (funct3)
          // ADD, ADDI, SUB
          3'b000: begin
            assign alu_ctrl = (opcode[5] & funct7[5]) ? SUB : ADD;
          end
          // OR, ORI
          3'b110: begin
            assign alu_ctrl = OR;
          end
         // AND, ANDI
          3'b111: begin
            assign alu_ctrl = AND;
          end
          default: begin
            xcpt = 1;
          end
        endcase
      end
      default: begin
        xcpt = 1;
      end
    endcase
  end

endmodule
