`include "brisc_pkg.svh"

module control
  import brisc_pkg::*;
(
    input logic [ILEN-1:0] instr,
    output itype_e itype
);

  always_comb begin
    unique case (instr[OPCODE_BITS-1:0])
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
        itype = INVALID;
      end
    endcase
  end

endmodule
