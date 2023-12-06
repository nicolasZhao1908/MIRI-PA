`include "brisc_pkg.svh"

module control
  import brisc_pkg::*;
(
    input logic [ILEN-1:0] instr,
    output itype_e itype
);

  always_comb begin
    case (instr[OPCODE_BITS-1:0])
      OPCODE_LOAD: begin
        assign itype = I;
      end
      OPCODE_OP: begin
        assign itype = R;
      end
      OPCODE_STORE: begin
        assign itype = S;
      end
      OPCODE_BRANCH: begin
        assign itype = B;
      end
      default: begin
        assign itype = INVALID;
      end
    endcase
  end

endmodule
