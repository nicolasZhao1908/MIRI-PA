`include "brisc_pkg.svh"

module comparator #(
    parameter integer unsigned WIDTH = 1
) (
    input logic [WIDTH - 1:0] in_1,
    input logic [WIDTH - 1:0] in_2,
    output logic is_equal
);

  assign is_equal = &(in_1 ^ ~in_2);
endmodule
