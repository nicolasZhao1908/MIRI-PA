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
    output logic dcache_ready_out,

    input logic arbiter_grant_in,

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

  // Avoid combinational circular loop
  logic is_load, is_load_w, is_load_ww;

  logic stb_flush;
  logic [XLEN-1:0] stb_flush_data;
  logic [ADDRESS_WIDTH-1:0] stb_flush_addr;
  logic stb_read_ready;
  logic [XLEN-1:0] stb_read_data;
  logic [XLEN-1:0] stb_read_addr;
  logic [XLEN-1:0] stb_write_data;
  data_size_e stb_data_size;

  cpu_req_t cpu_req;
  cpu_result_t cpu_res;
  mem_req_t mem_req;
  mem_resp_t mem_resp;


  always_comb begin
    // Avoid combinational circular loop
    is_load = (result_src_out == FROM_C);
    is_load_w = (result_src_out == FROM_C);
    is_load_ww = (result_src_out == FROM_C);

    cpu_req.valid = (is_load_w | is_store) | stb_flush;
    cpu_req.rw = stb_flush;
    cpu_req.data = stb_flush_data;
    cpu_req.addr = stb_flush ? stb_flush_addr : alu_res_out;
    cpu_req.size = data_size_w;

    mem_resp.ready = fill_in;
    mem_resp.addr = fill_addr_in;
    mem_resp.data = fill_data_in;

    mem_req_out = mem_req.valid;
    mem_req_write_out = mem_req.rw;
    mem_req_addr_out = mem_req.addr;
    mem_req_data_out = mem_req.data;

    read_data_out = (stb_read_ready) ? stb_read_data : cpu_res.data;
    dcache_ready_out = stb_read_ready | cpu_res.ready | (~is_load_ww & ~is_store);
  end

  cache_top dcache (
      .clk(clk),
      .reset(reset),
      .cpu_req(cpu_req),
      .cpu_res(cpu_res),
      .arbiter_grant(arbiter_grant_in),
      .mem_req(mem_req),
      .mem_resp(mem_resp)
  );

  store_buffer stb (
      .clk(clk),
      .reset(reset),
      .enable(~mem_req_out),

      .data_size_in(data_size_w),

      .is_load (is_load),
      .is_store(is_store),
      .addr_in (alu_res_out),

      // Add entries
      .write_data_in(stb_write_data),

      // Remove entries
      .flush_data_out(stb_flush_data),
      .flush_addr_out(stb_flush_addr),
      .flush_out(stb_flush),

      // Fowarding and stalling
      .read_data_out (stb_read_data),
      .read_addr_out (stb_read_addr),
      .read_valid_out(stb_read_ready),
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
    end
  end
endmodule
