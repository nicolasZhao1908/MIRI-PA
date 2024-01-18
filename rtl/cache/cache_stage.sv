`include "brisc_pkg.svh"

module cache_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_in,
    input logic flush_in,

    input logic [XLEN-1:0] alu_res_in,
    output logic [XLEN-1:0] alu_res_out,
    input logic [XLEN-1:0] write_data_in,
    input logic [XLEN-1:0] pc_plus4_in,
    output logic [XLEN-1:0] pc_plus4_out,
    input logic [REG_BITS-1:0] rd_in,
    output logic [REG_BITS-1:0] rd_out,

    output logic [XLEN-1:0] read_data_out,

    input logic arbiter_grant_in,

    // For AUIPC
    input  logic [XLEN-1:0] pc_delta_in,
    output logic [XLEN-1:0] pc_delta_out,

    // From memory
    input logic fill_in,
    input logic [CACHE_LINE_WIDTH-1:0] fill_data_in,
    input logic [ADDRESS_WIDTH-1:0] fill_addr_in,

    // Request to arbiter
    output logic mem_req_out,
    output logic mem_req_write_out,
    output logic [CACHE_LINE_WIDTH-1:0] mem_req_data_out,
    output logic [ADDRESS_WIDTH-1:0] mem_req_addr_out,

    // Ctrl signals
    input logic reg_write_in,
    output logic reg_write_out,
    input result_src_e result_src_in,
    output result_src_e result_src_out,
    input logic mem_write_in,
    input data_size_e data_size_in
);
  data_size_e data_size_w;

  logic is_store;
  logic is_load;
  logic [XLEN-1:0] cache_write_data;
  logic [ADDRESS_WIDTH-1:0] cache_write_addr;
  logic [XLEN-1:0] cache_read_data;

  logic cache_write;
  logic stb_read_valid;
  logic is_mem;
  logic mem_req;

  logic [XLEN-1:0] stb_read_data;
  logic [XLEN-1:0] stb_read_addr;

  logic [XLEN-1:0] stb_write_data;
  data_size_e stb_data_size;
  stb_ctrl_e stb_ctrl;

  always_comb begin
    read_data_out = (stb_read_valid) ? stb_read_data : cache_read_data;
    is_load = (result_src_out == FROM_C);
    stb_ctrl = OTHER;

    is_mem = (is_load | is_store);

    if (is_load) begin
      stb_ctrl = IS_LOAD;
    end else if (is_store) begin
      stb_ctrl = IS_STORE;
    end
    // TODO: mem_req_out = mem_req | ~arbiter_grant_in;
    mem_req_out = mem_req;
  end

  cache_top dcache (
      .clk  (clk),
      .reset(reset),

      .addr(alu_res_out),
      .data_size(data_size_w),
      .read_data(cache_read_data),
      .is_mem(is_mem),

      // Arbiter
      .arbiter_grant(arbiter_grant_in),
      .mem_req(mem_req),
      .mem_req_addr(mem_req_addr_out),
      .mem_req_data(mem_req_data_out),
      .mem_req_write(mem_req_write_out),

      // Memory
      .mem_resp(fill_in),
      .mem_resp_data(fill_data_in),
      .mem_resp_addr(fill_addr_in),

      // STB
      .stb_write_data(cache_write_data),
      .stb_write_addr(cache_write_addr),
      .stb_write(cache_write),
      .stb_write_size(stb_data_size),
      .stb_read_valid(stb_read_valid)
  );


  store_buffer stb (
      .clk  (clk),
      .reset(reset),

      // Don't flush when memory is requesting
      .enable(~mem_req_out),

      .data_size_in(data_size_w),

      // Is load or store?
      .stb_ctrl_in(stb_ctrl),
      .addr_in(alu_res_out),

      // Add entries
      .write_data_in(stb_write_data),

      // Remove entries
      .cache_write_data_out(cache_write_data),
      .cache_write_addr_out(cache_write_addr),
      .cache_write_out(cache_write),

      // Fowarding and stalling
      .read_data_out (stb_read_data),
      .read_addr_out (stb_read_addr),
      .read_valid_out(stb_read_valid),
      .data_size_out (stb_data_size)
  );

  // Pipeline registers ALU -> C
  always_ff @(posedge clk) begin
    if (reset | flush_in) begin
      stb_write_data <= 0;
      alu_res_out <= 0;
      pc_plus4_out <= 0;
      rd_out <= 0;

      // Ctrl signals
      is_store <= 0;
      reg_write_out <= 0;
      result_src_out <= result_src_e'(0);
      data_size_w <= data_size_e'(0);
      pc_delta_out <= 0;

    end else if (~stall_in) begin
      stb_write_data <= write_data_in;
      alu_res_out <= alu_res_in;
      pc_plus4_out <= pc_plus4_in;
      rd_out <= rd_in;

      // Ctrl signals
      is_store <= mem_write_in;
      reg_write_out <= reg_write_in;
      result_src_out <= result_src_in;
      data_size_w <= data_size_in;
      pc_delta_out <= pc_delta_in;
    end
  end
endmodule
