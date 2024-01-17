`include "brisc_pkg.svh"

module cache_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_in,
    input logic flush_in,

    input logic [XLEN-1:0] alu_res_in,
    input logic [XLEN-1:0] write_data_in,
    input logic [XLEN-1:0] pc_plus4_in,
    input logic [REG_BITS-1:0] rd_in,
    output logic [XLEN-1:0] alu_res_out,
    output logic [XLEN-1:0] read_data_out,
    output logic [XLEN-1:0] pc_plus4_out,
    output logic [REG_BITS-1:0] rd_out,

    output logic stall_out,

    // FOR AUIPC
    input logic [XLEN-1:0] pc_delta_in,
    output logic [XLEN-1:0] pc_delta_out,

    // From memory
    input logic fill_in,
    input logic [CACHE_LINE_WIDTH-1:0] fill_data_in,
    input logic [ADDRESS_WIDTH-1:0] fill_addr_in,

    // Request to arbiter
    output logic mem_req_out,
    output logic [CACHE_LINE_WIDTH-1:0] mem_req_data_out,
    output logic [ADDRESS_WIDTH-1:0] mem_req_addr_out,
    output logic mem_req_write_out,

    // CTRL SIGNALS
    input logic reg_write_in,
    input result_src_e result_src_in,
    input logic mem_write_in,
    input data_size_e data_size_in,
    output logic reg_write_out,
    output result_src_e result_src_out
);
  result_src_e result_src_w;
  data_size_e data_size_w;
  logic [XLEN-1:0] alu_res_w;

  // TODO: why do I need it?
  logic arbiter_grant;

  logic is_store;
  logic is_load;
  /* verilator lint_off UNOPTFLAT */
  logic [XLEN-1:0] cache_write_data;
  logic [ADDRESS_WIDTH-1:0] cache_write_addr;
  logic [XLEN-1:0] cache_read_data;
  logic cache_write;
  logic cache_miss;

  logic stb_read_valid;
  logic [XLEN-1:0] stb_read_data;
  logic [XLEN-1:0] stb_read_addr;

  logic [XLEN-1:0] stb_write_data;
  data_size_e stb_data_size;
  stb_ctrl_e stb_ctrl;

  always_comb begin
    stall_out = cache_miss | mem_req_out | cache_write;
    result_src_out = result_src_w;
    alu_res_out = alu_res_w;
    read_data_out = (stb_read_valid) ? stb_read_data : cache_read_data;
    is_load = (result_src_w == FROM_C);

    if (is_load) begin
      stb_ctrl = IS_LOAD;
    end else if (is_store) begin
      stb_ctrl = IS_STORE;
    end else begin
      stall_out = 0;
      stb_ctrl = OTHER;
    end
  end

  cache_top dcache (
      // PIPELINE
      .clk(clk),
      .reset(reset),
      .enable(is_store & ~stall_in),
      .is_load(is_load),
      .addr(alu_res_w),
      .data_size(data_size_w),
      .miss(cache_miss),
      .read_data(cache_read_data),

      // ARBITER
      .arbiter_grant(arbiter_grant),
      .arbiter_req  (mem_req_out),
      .mem_req_addr (mem_req_addr_out),
      .mem_req_data (mem_req_data_out),
      .mem_req_write(mem_req_write_out),

      // MEMORY
      .mem_resp(fill_in),
      .mem_resp_data(fill_data_in),
      .mem_resp_addr(fill_addr_in),

      // SB
      .stb_write_data(cache_write_data),
      .stb_write_addr(cache_write_addr),
      .stb_write(cache_write),
      .stb_write_size(stb_data_size),
      .stb_read_valid(stb_read_valid)
  );


  store_buffer stb (
      .clk(clk),
      .reset(reset),
      // don't flush when memory is requesting
      .wait_mem(mem_req_out),
      .data_size_in(data_size_w),

      // IS LOAD OR STORE?
      .stb_ctrl_in(stb_ctrl),
      .addr_in(alu_res_w),

      // ADD ENTRIES
      .write_data_in(stb_write_data),

      // REMOVE ENTRIES
      .cache_write_data_out(cache_write_data),
      .cache_write_addr_out(cache_write_addr),
      .cache_write_out(cache_write),

      // FOWARDING AND STALLING
      .read_data_out (stb_read_data),
      .read_addr_out (stb_read_addr),
      .read_valid_out(stb_read_valid),
      .data_size_out (stb_data_size)
  );

  // Pipeline registers ALU -> C
  always_ff @(posedge clk) begin
    if (reset | flush_in) begin
      stb_write_data <= 0;
      alu_res_w <= 0;
      pc_plus4_out <= 0;
      rd_out <= 0;
      // CTRL SIGNALS
      is_store <= 0;
      reg_write_out <= 0;
      result_src_w <= result_src_e'(0);
      data_size_w <= data_size_e'(0);
      pc_delta_out <= 0;
    end else if (~stall_in) begin
      stb_write_data <= write_data_in;
      alu_res_w <= alu_res_in;
      pc_plus4_out <= pc_plus4_in;
      rd_out <= rd_in;
      // CTRL SIGNALS
      is_store <= mem_write_in;
      reg_write_out <= reg_write_in;
      result_src_w <= result_src_in;
      data_size_w <= data_size_in;
      pc_delta_out <= pc_delta_in;
    end
  end
endmodule
