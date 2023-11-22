module ff #(
    parameter WIDTH = 1,
    parameter RESET_VALUE = 0
)

(
    input logic clk,
    input logic enable,
    input logic reset,   // active high synchronous reset
    input logic [WIDTH - 1:0] inp,
    output logic [WIDTH - 1:0] out
);
    
    always @(posedge clk) begin
        if (reset)
            out <= RESET_VALUE;
        else
            if (enable)
                out <= inp;
            else
                out <= out;
    end

endmodule

module nff #(
    parameter N = 3,
    parameter WIDTH = 1,
    parameter RESET_VALUE = 0
) (
    input logic clk,
    input logic enable,
    input logic reset,   // active high synchronous reset
    input logic [WIDTH - 1:0] inp,
    output logic [WIDTH - 1:0] out
);

    logic [WIDTH - 1:0] inp_cable [N + 1];

    assign inp_cable[0] = inp;

    genvar i;
    generate
        for(i = 0; i < N; i++) begin
            ff #(.WIDTH(WIDTH), .RESET_VALUE(RESET_VALUE)) flip_flop
            (clk, enable, reset, inp_cable[i], inp_cable[i + 1]);
        end
    endgenerate

    assign out = inp_cable[N];

endmodule