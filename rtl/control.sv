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
    is_valid = 1;
    unique case (opcode)
      opcode_e::OPCODE_LOAD: begin
         itype =  itype_e::I;
      end
      opcode_e::OPCODE_OP: begin
         itype =  itype_e::R;
      end
      opcode_e::OPCODE_STORE: begin
        itype = itype_e::S;
      end
      opcode_e::OPCODE_BRANCH: begin
        itype = itype_e::B;
      end
      default: begin
        is_valid = 0;
      end
    endcase
  end

endmodule
