`include "brisc_pkg.svh"

module core
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,


    // For memory
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
  pc_src_e pc_src_A_F;
  logic [XLEN-1:0] pc_F;
  logic [XLEN-1:0] pc_plus4_F;
  logic [ILEN-1:0] instr_F;
  logic fetch_busy;

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

  logic [XLEN-1:0] pc_delta_A;
  logic [REG_BITS-1:0] rd_A;
  logic [REG_BITS-1:0] rs1_A;
  logic [REG_BITS-1:0] rs2_A;
  logic [XLEN-1:0] write_data_A;
  logic [XLEN-1:0] pc_plus4_A;
  logic [XLEN-1:0] alu_res_A;
  fwd_src_e fwd_src1_A;
  fwd_src_e fwd_src2_A;
  logic flush_A;
  logic reg_write_A;
  result_src_e result_src_A;
  logic mem_write_A;
  data_size_e data_size_A;
  logic stall_A;

  logic [XLEN-1:0] pc_delta_C;
  logic [XLEN-1:0] read_data_C;
  logic [XLEN-1:0] alu_res_C;
  logic [REG_BITS-1:0] rd_C;
  logic reg_write_C;
  result_src_e result_src_C;
  logic [XLEN-1:0] pc_plus4_C;
  logic dcache_busy;
  logic stall_C;

  logic [XLEN-1:0] result_WB;
  logic [REG_BITS-1:0] rd_WB;
  logic reg_write_WB;
  logic flush_WB;

  // Logic for arb
  logic arb_req_dcache;
  logic arb_req_dcache_write;
  logic [ADDRESS_WIDTH-1:0] arb_req_dcache_address;
  logic [CACHE_LINE_WIDTH-1:0] arb_req_dcache_evict_data;

  /* verilator lint_off UNOPTFLAT */
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
      .pc_src_in(pc_src_A_F),
      .pc_target_in(pc_delta_A),
      .pc_out(pc_F),
      .instr_out(instr_F),
      .pc_plus4_out(pc_plus4_F),
      .busy_out(fetch_busy),

      //Cache
      .arbiter_grant(grant_icache),
      .arbiter_req  (arb_req_icache),
      .mem_req_addr (arb_req_icache_address),
      .mem_req_data (arb_req_icache_evict_data),
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
      .stall_in(stall_A),
      .flush_in(flush_A),
      .fwd_src1_in(fwd_src1_A),
      .fwd_src2_in(fwd_src2_A),
      .pc_plus4_in(pc_plus4_D),

      .rs1_data_in (rs1_data_D),
      .rs2_data_in (rs2_data_D),
      .alu_res_C_in(alu_res_C),
      .result_WB_in(result_WB),

      .rd_in (rd_D),
      .rs1_in(rs1_D),
      .rs2_in(rs2_D),
      .imm_in(imm_D),
      .pc_in (pc_D),

      // OUT
      .pc_src_out(pc_src_A_F),
      .pc_target_out(pc_delta_A),
      .alu_res_out(alu_res_A),
      .pc_plus4_out(pc_plus4_A),
      .rd_out(rd_A),
      .rs1_out(rs1_A),
      .rs2_out(rs2_A),
      // data to write into memory (rf[rs2])
      .write_data_out(write_data_A),

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
      .reg_write_out(reg_write_A),
      .result_src_out(result_src_A),
      .mem_write_out(mem_write_A),
      .data_size_out(data_size_A),
      .xcpt_out()
  );

  cache_stage cache (
      .clk(clk),
      .reset(reset),
      .stall_in(stall_C),
      .flush_in(0),
      .stall_out(dcache_busy),
      .fill_in(mem_fill_valid),
      .fill_data_in(mem_fill_data),
      .fill_addr_in(mem_fill_addr),
      .mem_req_out(arb_req_dcache),
      .mem_req_data_out(arb_req_dcache_evict_data),
      .mem_req_addr_out(arb_req_dcache_address),
      .mem_req_write_out(arb_req_dcache_write),
      .alu_res_in(alu_res_A),
      .write_data_in(write_data_A),
      .pc_plus4_in(pc_plus4_A),
      .pc_delta_in(pc_delta_A),
      .pc_delta_out(pc_delta_C),
      .rd_in(rd_A),
      .alu_res_out(alu_res_C),
      .read_data_out(read_data_C),
      .pc_plus4_out(pc_plus4_C),
      .rd_out(rd_C),
      // CTRL signals
      .data_size_in(data_size_A),
      .reg_write_in(reg_write_A),
      .mem_write_in(mem_write_A), // is_store
      .result_src_in(result_src_A), // is_load
      .reg_write_out(reg_write_C),
      .result_src_out(result_src_C)
  );

  wb_stage write_back (
      .clk(clk),
      .reset(reset),
      .flush_in(flush_WB),
      .alu_res_in(alu_res_C),
      .read_data_in(read_data_C),
      .pc_plus4_in(pc_plus4_C),
      .pc_delta_in(pc_delta_C),
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
      .rs1_A_in(rs1_A),
      .rs2_A_in(rs2_A),
      .rs1_D_in(rs1_D),
      .rs2_D_in(rs2_D),
      .rd_A_in(rd_A),
      .rd_C_in(rd_C),
      .rd_WB_in(rd_WB),
      .reg_write_C_in(reg_write_C),
      .reg_write_WB_in(reg_write_WB),
      .result_src_A_in(result_src_A),
      .dcache_busy_in(dcache_busy),
      .icache_busy_in(fetch_busy),
      .pc_src_in(pc_src_A_F),
      .fwd_src1_out(fwd_src1_A),
      .fwd_src2_out(fwd_src2_A),
      .stall_F_out(stall_F),
      .stall_D_out(stall_D),
      .flush_D_out(flush_D),
      .flush_A_out(flush_A),
      .stall_C_out(stall_C),
      .stall_A_out(stall_A),
      .flush_WB_out(flush_WB)

  );

  // lw r1 <- ljla
  // add r2 <- r1,r3

  arbiter arb (
      .clk(clk),

      .mem_req_1  (arb_req_dcache),
      .mem_write_1(arb_req_dcache_write),
      .mem_addr_1 (arb_req_dcache_address),
      .mem_data_1 (arb_req_dcache_evict_data),

      .mem_req_2  (arb_req_icache),
      .mem_write_2(arb_req_icache_write),
      .mem_addr_2 (arb_req_icache_address),
      .mem_data_2 (arb_req_icache_evict_data),

      .grant_1  (grant_dcache),
      .grant_2  (grant_icache),
      .mem_req  (mem_req),
      .mem_write(mem_store),
      .mem_addr (mem_addr),
      .mem_data (mem_data)

  );
endmodule
