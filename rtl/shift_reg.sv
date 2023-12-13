module shift_reg
#(
    parameter int unsigned WIDTH = 32,
    parameter int unsigned N = 1
)
(
    input clk,
    input reset,
    input enable,

    input [WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_out
);

// reg
logic [WIDTH-1:0] regs[N];
assign data_out = regs[N-1];

int unsigned i;
always_ff @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < N; i++) begin
            regs[i] <= 0;
        end
    end else if (enable) begin
        regs[0] <= data_in;
        for (i = 1; i < N;  i++) begin
            regs[i] <= regs[i-1];
        end
    end
end

endmodule
