`include "brisc_pkg.svh"

module fetch_stage
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset,
    input logic stall_in,
    input pc_src_e pc_src_in,
    input xcpt_e xcpt_in,
    input logic [ADDRESS_WIDTH-1:0] pc_target_in,
    output logic [ILEN-1:0] instr_out,
    output logic [XLEN-1:0] pc_out,
    output logic [XLEN-1:0] pc_plus4_out
);

  logic [XLEN-1:0] pc_next;
  logic cache_miss;
  logic stall_pc;

  assign pc_next = (xcpt_in != NO_XCPT) ? PC_XCPT :
                  ((pc_src_in == FROM_EX) ? pc_target_in : pc_out + 4);
  assign pc_plus4_out = pc_next;

  always_ff @(posedge clk) begin
    if (reset) begin
      pc_out <= PC_BOOT;
    end else if (~stall_in) begin
      pc_out <= pc_next;
    end
  end

endmodule
