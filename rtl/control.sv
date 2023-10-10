`include "brisc_pkg.svh"

module control
  import brisc_pkg::*;
(
    input logic [ILEN-1:0] instr,
    output itype_e itype,
    output logic is_valid
);

  logic [OPCODE_BITS-1:0] opcode;
  assign opcode = instr[OPCODE_BITS-1:0];
  always_comb begin
  end

endmodule
