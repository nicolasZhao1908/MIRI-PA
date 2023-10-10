`include "const.svh"

module control#(
    parameter OPCODE_LW = `OPCODE_LW,
    parameter OPCODE_LB = `OPCODE_LB,
    parameter OPCODE_ADDI = `OPCODE_ADDI,
    parameter OPCODE_SW = `OPCODE_SW,
    parameter OPCODE_SB = `OPCODE_SB,
    parameter OPCODE_BEQ = `OPCODE_BEQ,
    parameter OPCODE_JUMP = `OPCODE_JUMP,
    parameter OPCODE_ADD = `OPCODE_ADD,
    parameter OPCODE_SUB = `OPCODE_SUB,
    parameter OPCODE_MUL = `OPCODE_MUL,
    parameter NOP = `NOP,
    parameter ILEN = `ILEN,
    parameter OPCODE_BITS = `OPCODE_BITS
)(
    input logic [ILEN-1:0] instr,
    output instr_type itype,
    output logic  is_valid
);

logic [OPCODE_BITS-1:0] opcode;
assign opcode = instr[OPCODE_BITS-1:0];
always_comb begin
end

endmodule