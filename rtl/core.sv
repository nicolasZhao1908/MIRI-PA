`include "brisc_pkg.svh"
`include "cache/dcache.sv"
`include "utility/ff.sv"

module core
  import brisc_pkg::*;
#(
) (
    input logic clk,
    input logic reset
);
  //STALL LOGIC
  logic stall_fetch;

  //Exception
  logic xcpt_decode;

  //MEM UTIL
  logic enable_2;
  logic store_2;
  logic word_2;
  logic [ADDRESS_BITS-1:0] addr_2;
  logic [XLEN-1:0] data_in_2;
  logic hit_2;
  logic [XLEN-1:0] data_out_2;


  logic [CACHE_LINE_LEN-1:0] mem_fill;
  logic mem_valid;
  logic req_store_to_mem_1;
  logic [ADDRESS_BITS-1:0] req_addr_to_mem_1;
  logic [XLEN-1:0] req_store_data_to_mem_1;
  logic req_word_to_mem_1;
  logic [ADDRESS_BITS-1:0] req_addr_to_mem_2;
  logic req_to_mem_arb;
  logic req_store_to_mem_arb;
  logic [ADDRESS_BITS-1:0] req_addr_to_mem_arb;
  logic [XLEN-1:0] req_store_data_to_mem_arb;
  logic req_store_word_to_mem_arb;
  logic dreq_arb;
  logic ireq_arb;
  logic dgrant;
  logic igrant;

  //----------------------------------- IFETCH ------------------------------------
  logic [ILEN-1:0] instr_fetch;

  ifetch_stage fetch (
      .clk(clk),
      .reset(reset),
      .xcpt(xcpt_fetch),
      .stall_fetch(stall_fetch),
      .b_taken(b_taken),
      .b_target(alu_res_ex),
      .arbiter_grant(igrant),
      .fill_data_from_mem(mem_fill),
      .fill_data_from_mem_valid(mem_valid),
      .req_addr_to_mem(req_addr_to_mem_2),
      .req_to_arbiter(ireq_arb),
      .instr(instr_fetch),
      .stall(stall_fetch)  //TODO send nops down
  );

  instr_e instr_decode;
  logic [XLEN-1:0] rs1_data_decode;
  logic [XLEN-1:0] rs2_data_decode;
  logic [XLEN-1:0] imm_decode;
  logic [REG_BITS-1:0] rd_decode;
  logic stall_decode;
  assign stall_decode = 0;
  logic xcpt_fetch;
  assign xcpt_fetch = xcpt_decode | 0;

  logic [OPCODE_BITS-1:0] opcode_wb;
  logic [XLEN-1:0] write_data_wb;
  logic [REG_BITS-1:0] rd_wb;
  logic rf_en;

  decode_stage decode (
      .clk(clk),
      .reset(reset),
      .stall_decode(stall_decode),
      .rf_enable(rf_en),
      .instr_in(instr_fetch),
      .opcode_wb_in(opcode_wb),
      .data_wb_in(write_data_wb),
      .rd_wb_in(rd_wb),
      .rd_out(rd_decode),
      .rs1_data_out(rs1_data_decode),
      .rs2_data_out(rs2_data_decode),
      .imm_out(imm_decode),
      .xcpt(xcpt_decode),
      .instr_out(instr_decode)
  );

  instr_e instr_ex;
  logic [XLEN-1:0] alu_res_ex;
  logic [REG_BITS-1:0] rd_ex;
  logic b_taken;
  logic stall_ex;
  assign stall_ex = 0;

  ex_stage execute (
      .clk(clk),
      .reset(reset),  // high reset
      .stall_ex(stall_ex),
      .instr_in(instr_decode),
      .rs1_data_in(rs1_data_decode),
      .rs2_data_in(rs2_data_decode),
      .rd_in(rd_decode),
      .imm_in(imm_decode),
      .b_taken(b_taken),
      .alu_res(alu_res_ex),
      .instr_out(instr_ex),
      .rd_out(rd_ex)
  );

  logic is_store;
  logic is_word;
  // TODO connect is_mem with dcache
  logic is_mem;
  logic dcache_en;
  logic dcache_hit;
  assign is_mem = (instr_ex == SW) || (instr_ex == SB) || (instr_ex == LW) || (instr_ex == LB);
  assign is_word = is_mem && (instr_ex == SW) || (instr_ex == LW);
  assign is_store = (instr_ex == SW) || (instr_ex == SB);
  assign dcache_en = (instr_ex == SW) || (instr_ex == SB);

  logic [XLEN-1:0] dcache_data_c;

  dcache #(
      .SET_BIT_WIDTH(2),
      .ADDRESS_WIDTH(ADDRESS_BITS),
      .DATA_WIDTH(XLEN),
      .CACHE_LINE_WIDTH(CACHE_LINE_LEN)
  ) dcache_unit (
      // cache input
      .clk(clk),
      .enable(dcache_en),
      .store(is_store),
      .addr(alu_res_ex),
      .data_in(rs2_data_decode),
      .word(is_word),
      // arbiter input
      .arbiter_grant(dgrant),
      // arbiter output
      .req_to_arbiter(dreq_arb),
      // mem input
      .fill_data_from_mem(mem_fill),
      .fill_data_from_mem_valid(mem_valid),

      // mem output
      .req_store_to_mem(req_store_to_mem_1),
      .req_addr_to_mem(req_addr_to_mem_1),
      .req_store_data_to_mem(req_store_data_to_mem_1),
      .req_word_to_mem(req_word_to_mem_1),

      // cache output
      .hit(dcache_hit),
      .data_out(dcache_data_c)
  );

  arbiter arb (
      .clk(clk),
      .req_1(dreq_arb),
      .store_to_mem_1(req_store_to_mem_1),
      .addr_to_mem_1(req_addr_to_mem_1),
      .data_to_mem_1(req_store_data_to_mem_1),
      .store_word_1(req_word_to_mem_1),
      .req_2(ireq_arb),
      .store_to_mem_2(1'b0),
      .addr_to_mem_2(req_addr_to_mem_2),
      .data_to_mem_2('0),
      .store_word_2(1'b0),
      .grant_1(dgrant),
      .grant_2(igrant),
      .request_to_mem(req_to_mem_arb),
      .store_to_mem(req_store_to_mem_arb),
      .addr_to_mem(req_addr_to_mem_arb),
      .data_to_mem(req_store_data_to_mem_arb),
      .store_word_to_mem(req_store_word_to_mem_arb)
  );
  memory #(
      .FILL_DATA_WIDTH(CACHE_LINE_LEN),
      .ADDRESS_WIDTH(ADDRESS_BITS),
      .STORE_DATA_WIDTH(8)
  ) mem (
      .clk(clk),
      .req(req_to_mem_arb),
      .store(req_store_to_mem_arb),
      .storeWord(req_store_word_to_mem_arb),
      .address(req_addr_to_mem_arb),
      .evict_data(req_store_data_to_mem_arb),
      .fill_data(mem_fill),
      .response_valid(mem_valid)
  );
  logic [XLEN-1:0] opcode_c;

  wb_stage wb (
      .clk(clk),
      .reset(reset),
      .opcode_in(opcode_c),
      .alu_res_in(write_data_c),
      .mem_data_in(mem_data_c),
      .rd_in(rd_c),
      .rd_out(),
      .rd_data_out(),
      .write_rf(rf_en)
  );

endmodule
