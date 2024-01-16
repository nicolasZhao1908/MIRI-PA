`include "brisc_pkg.svh"

module core
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,


    //For memory
    input logic [CACHE_LINE_WIDTH-1:0] mem_fill_data,
    input logic [ADDRESS_WIDTH-1:0] mem_fill_addr,
    input logic mem_fill_valid,

    output logic mem_req,
    output logic mem_store,
    output logic [ADDRESS_WIDTH-1:0] mem_addr,
    output logic [CACHE_LINE_WIDTH-1:0] mem_data
    // TODO: put icache and dcache request and response
);
  logic stall_F;
  pc_src_e pc_src_EX_F;
  logic [XLEN-1:0] pc_target_EX_F;
  logic [XLEN-1:0] pc_F;
  logic [XLEN-1:0] pc_plus4_F;
  logic [ILEN-1:0] instr_F;

  logic stall_D;
  logic flush_D;
  logic [REG_BITS-1:0] rd_D;
  logic [REG_BITS-1:0] rs1_D;
  logic [REG_BITS-1:0] rs2_D;
  logic [XLEN-1:0] rs1_data_D;
  logic [XLEN-1:0] rs2_data_D;
  logic [XLEN-1:0] imm_D;
  logic [XLEN-1:0] pc_D;
  logic [XLEN-1:0] pc_plus4_D;
  logic reg_write_D;
  result_src_e result_src_D;
  logic mem_write_D;
  logic is_branch_D;
  logic is_jump_D;
  alu_ctrl_e alu_ctrl_D;
  alu_src_e alu_src_D;
  data_size_e data_size_D;
  xcpt_e xcpt_D;

  logic [REG_BITS-1:0] rd_EX;
  logic [REG_BITS-1:0] rs1_EX;
  logic [REG_BITS-1:0] rs2_EX;
  logic [XLEN-1:0] write_data_EX;
  logic [XLEN-1:0] pc_plus4_EX;
  logic [XLEN-1:0] alu_res_EX;
  fwd_src_e fwd_src1_EX;
  fwd_src_e fwd_src2_EX;
  logic flush_EX;
  logic reg_write_EX;
  result_src_e result_src_EX;
  logic mem_write_EX;
  data_size_e data_size_EX;

  logic [XLEN-1:0] read_data_C;
  logic [XLEN-1:0] alu_res_C;
  logic [REG_BITS-1:0] rd_C;
  logic reg_write_C;
  result_src_e result_src_C;
  logic [XLEN-1:0] pc_plus4_C;

  logic [XLEN-1:0] result_WB;
  logic [REG_BITS-1:0] rd_WB;
  logic reg_write_WB;

  //Logic for arb
  logic arb_req_dcache;
  logic arb_req_dcache_write;
  logic [ADDRESS_WIDTH-1:0] arb_req_dcache_address;
  logic [CACHE_LINE_WIDTH-1:0] arb_req_dcache_evict_data;

  logic arb_req_icache;
  logic arb_req_icache_write;
  logic [ADDRESS_WIDTH-1:0] arb_req_icache_address;
  logic [CACHE_LINE_WIDTH-1:0] arb_req_icache_evict_data;


  logic grant_dcache;
  logic grant_icache;


  fetch_stage fetch (
      .clk(clk),
      .reset(reset),
      .xcpt_in(xcpt_D),
      .stall_in(stall_F),
      .pc_src_in(pc_src_EX_F),
      .pc_target_in(pc_target_EX_F),
      .pc_out(pc_F),
      .instr_out(instr_F),
      .pc_plus4_out(pc_plus4_F),

      //Cache
      .arbiter_grant(grant_icache),
      .arbiter_req(arb_req_icache),
      .mem_req_addr(arb_req_icache_address),
      .mem_req_data(arb_req_icache_evict_data),
      .mem_req_write(arb_req_icache_write),

    // MEMORY
      .mem_resp(mem_fill_valid),
      .mem_resp_data(mem_fill_data),
      .mem_resp_addr(mem_fill_addr)
  );

  decode_stage decode (
      .clk(clk),
      .reset(reset),
      .flush_in(flush_D),
      .stall_in(stall_D),
      .instr_in(instr_F),
      .pc_in(pc_F),

      .result_WB_in(result_WB),
      .rd_WB_in(rd_WB),
      .reg_write_WB_in(reg_write_WB),

      .pc_plus4_in(pc_plus4_F),

      .rd_out(rd_D),
      .rs1_out(rs1_D),
      .rs2_out(rs2_D),
      .pc_out(pc_D),
      .rs1_data_out(rs1_data_D),
      .rs2_data_out(rs2_data_D),
      .imm_out(imm_D),
      .pc_plus4_out(pc_plus4_D),

      // CTRL signals
      .reg_write_out(reg_write_D),
      .result_src_out(result_src_D),
      .mem_write_out(mem_write_D),
      .is_jump_out(is_jump_D),
      .is_branch_out(is_branch_D),
      .alu_ctrl_out(alu_ctrl_D),
      .alu_src_out(alu_src_D),
      .data_size_out(data_size_D),
      .xcpt_out(xcpt_D)
  );

  alu_stage alu (
      // IN
      .clk(clk),
      .reset(reset),  // high reset
      .stall_in(),
      .flush_in(flush_EX),
      .fwd_src1_in(fwd_src1_EX),
      .fwd_src2_in(fwd_src2_EX),
      .pc_plus4_in(pc_plus4_D),

      .rs1_data_in(rs1_data_D),
      .rs2_data_in(rs2_data_D),
      .alu_res_C_in (alu_res_C),
      .result_WB_in (result_WB),

      .rd_in (rd_D),
      .rs1_in(rs1_D),
      .rs2_in(rs2_D),
      .imm_in(imm_D),
      .pc_in (pc_D),

      // OUT
      .pc_src_out(pc_src_EX_F),
      .pc_target_out(pc_target_EX_F),
      .alu_res_out(alu_res_EX),
      .pc_plus4_out(pc_plus4_EX),
      .rd_out(rd_EX),
      .rs1_out(rs1_EX),
      .rs2_out(rs2_EX),
      // data to write into memory (rf[rs2])
      .write_data_out(write_data_EX),

      // IN: ctrl signals
      .reg_write_in(reg_write_D),
      .mem_write_in(mem_write_D),
      .result_src_in(result_src_D),
      .alu_ctrl_in(alu_ctrl_D),
      .alu_src_in(alu_src_D),
      .is_branch_in(is_branch_D),
      .is_jump_in(is_jump_D),
      .data_size_in(data_size_D),

      // OUT: ctrl signals
      .reg_write_out (reg_write_EX),
      .result_src_out(result_src_EX),
      .mem_write_out (mem_write_EX),
      .data_size_out (data_size_EX),
      .xcpt_out()
  );

  cache_stage cache (
      .clk(clk),
      .reset(reset),
      .stall_in(),
      .flush_in(),
      .stall_out(),
      .fill_in(mem_fill_valid),
      .fill_data_in(mem_fill_data),
      .fill_addr_in(mem_fill_addr),
      .mem_req_out(arb_req_dcache),
      .mem_req_data_out(arb_req_dcache_evict_data),
      .mem_req_addr_out(arb_req_dcache_address),
      .mem_req_write_out(arb_req_dcache_write),
      .alu_res_in(alu_res_EX),
      .write_data_in(write_data_EX),
      .pc_plus4_in(pc_plus4_EX),
      .rd_in(rd_EX),
      .alu_res_out(alu_res_C),
      .read_data_out(read_data_C),
      .pc_plus4_out(pc_plus4_C),
      .rd_out(rd_C),
    //   .write_data_out(mem_write_data),
      // CTRL signals
      .data_size_in(data_size_EX),
      .reg_write_in(reg_write_EX),
      .mem_write_in(mem_write_EX),
      .result_src_in(result_src_EX),
      .reg_write_out(reg_write_C),
      .result_src_out(result_src_C)
  );

  wb_stage write_back (
      .clk(clk),
      .reset(reset),
      .stall_in(),
      .alu_res_in(alu_res_C),
      .read_data_in(read_data_C),
      .pc_plus4_in(pc_plus4_C),
      .rd_in(rd_C),
      .rd_out(rd_WB),
      .result_out(result_WB),
      // CTRL signals
      .result_src_in(result_src_C),
      .reg_write_in(reg_write_C),
      .reg_write_out(reg_write_WB)
  );

  // TODO: pass here fetch and cache stage stall logic
  // fetch stage: stall on mem_request (cache miss)
  // cache stage: stall on mem_request (load cache miss or eviction [store cache miss])
  //            or stb_flush
  hazard hazard_unit (
      .rs1_EX_in(rs1_EX),
      .rs2_EX_in(rs2_EX),
      .rs1_D_in(rs1_D),
      .rs2_D_in(rs2_D),
      .rd_EX_in(rd_EX),
      .rd_C_in(rd_C),
      .rd_WB_in(rd_WB),
      .reg_write_C_in(reg_write_C),
      .reg_write_WB_in(reg_write_WB),
      .result_src_EX_in(result_src_EX),
      .pc_src_in(pc_src_EX_F),
      .fwd_src1_out(fwd_src1_EX),
      .fwd_src2_out(fwd_src2_EX),
      .stall_F_out(stall_F),
      .stall_D_out(stall_D),
      .flush_D_out(flush_D),
      .flush_EX_out(flush_EX)
  );

  arbiter arb
    (
    .clk(clk),

    .mem_req_1(arb_req_dcache),
    .mem_write_1(arb_req_dcache_write),
    .mem_addr_1(arb_req_dcache_address),
    .mem_data_1(arb_req_dcache_evict_data),

    .mem_req_2(arb_req_icache),
    .mem_write_2(arb_req_icache_write),
    .mem_addr_2(arb_req_icache_address),
    .mem_data_2(arb_req_icache_evict_data),

    .grant_1(grant_dcache),
    .grant_2(grant_icache),
    .mem_req(mem_req),
    .mem_write(mem_store),
    .mem_addr(mem_addr),
    .mem_data(mem_data)

  );
endmodule
