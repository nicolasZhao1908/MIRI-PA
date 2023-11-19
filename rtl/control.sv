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
      OPCODE_LOAD: begin
        itype = I;
      end
      OPCODE_OP: begin
        itype = R;
      end
      OPCODE_STORE: begin
        itype = S;
      end
      OPCODE_BRANCH: begin
        itype = B;
      end
      default: begin
        itype = I;
        is_valid = 0;
      end
    endcase
  end

endmodule
