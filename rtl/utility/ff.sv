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