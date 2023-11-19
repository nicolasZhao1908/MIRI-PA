module comparator #(
    parameter WIDTH = 1
)
(
    input logic [WIDTH - 1:0] inp_1,
    input logic [WIDTH - 1:0] inp_2,
    output logic is_equal
);

    assign is_equal = & (inp_1 ^ ~inp_2);
endmodule