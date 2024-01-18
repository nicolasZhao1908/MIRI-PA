`include "brisc_pkg.svh"

module decode_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_in,
    input logic flush_in,
    input logic [ILEN-1:0] instr_in,
    input logic [XLEN-1:0] pc_in,

    // from WB stage
    input logic [XLEN-1:0] result_WB_in,
    input logic [REG_BITS-1:0] rd_WB_in,
    input logic reg_write_WB_in,

    // for JUMP
    input logic [XLEN-1:0] pc_plus4_in,

    output logic [REG_BITS-1:0] rd_out,
    output logic [REG_BITS-1:0] rs1_out,
    output logic [REG_BITS-1:0] rs2_out,
    output logic [XLEN-1:0] pc_out,
    output logic [XLEN-1:0] rs1_data_out,
    output logic [XLEN-1:0] rs2_data_out,
    output logic [XLEN-1:0] imm_out,
    output logic [XLEN-1:0] pc_plus4_out,

    // ctrl signals
    output logic reg_write_out,
    output result_src_e result_src_out,
    output logic mem_write_out,
    output logic is_branch_out,
    output logic is_jump_out,
    output alu_ctrl_e alu_ctrl_out,
    output alu_src1_e alu_src1_out,
    output alu_src2_e alu_src2_out,
    output data_size_e data_size_out,
    output xcpt_e xcpt_out
);


  logic [ILEN-1:0] instr_w;
  logic [XLEN-1:0] imm_w;
  imm_src_e imm_src_w;

  ctrl ctrl_unit (
      // IN
      .funct3(instr_w[14:12]),
      .funct7(instr_w[31:25]),
      .opcode(instr_w[OPCODE_WIDTH-1:0]),
      // OUT
      .reg_write(reg_write_out),
      .imm_src(imm_src_w),
      .result_src(result_src_out),
      .alu_src1(alu_src1_out),
      .alu_src2(alu_src2_out),
      .alu_ctrl(alu_ctrl_out),
      .mem_write(mem_write_out),
      .is_branch(is_branch_out),
      .is_jump(is_jump_out),
      .data_size(data_size_out),
      .xcpt(xcpt_out)
  );

  regfile rfile (
      // IN
      .clk(clk),
      .reset(reset),
      .rs1_addr(rs1_out),
      .rs2_addr(rs2_out),
      .write_data(result_WB_in),
      .rd_addr(rd_WB_in),
      .enable(reg_write_WB_in),
      // OUT
      .rs1_data(rs1_data_out),
      .rs2_data(rs2_data_out)
  );

  always_comb begin
    rs1_out = instr_w[19:15];
    rs2_out = instr_w[24:20];
    rd_out  = instr_w[11:7];
    unique case (imm_src_w)
      I_IMM: begin
        imm_out = {{20{instr_w[31]}}, instr_w[31:20]};

      end
      S_IMM: begin
        imm_out = {{20{instr_w[31]}}, instr_w[31:25], instr_w[11:7]};
      end
      B_IMM: begin
        imm_out = {{20{instr_w[31]}}, instr_w[7], instr_w[30:25], instr_w[11:8], 1'b0};
      end
      J_IMM: begin
        imm_out = {{12{instr_w[31]}}, instr_w[19:12], instr_w[20], instr_w[30:21], 1'b0};
      end
      U_IMM: begin
        imm_out = {instr_w[31:12], {12{1'b0}}};
      end
      default: begin
        imm_out = 'bx;  // undefined
      end
    endcase
  end

  // Pipeline registers F -> D
  always_ff @(posedge clk) begin
    if (reset | flush_in) begin
      instr_w <= NOP;
      pc_out <= 0;
      pc_plus4_out <= 0;
    end else if (~stall_in) begin
      instr_w <= instr_in;
      pc_out <= pc_in;
      pc_plus4_out <= pc_plus4_in;
    end
  end

endmodule
