
module add_sub #(
    parameter N = 32
) (
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic sub,
    output logic [N-1:0] out,
    output logic cout
);
    logic [N-1:0] adjusted_b;
    assign adjusted_b = b[N - 1:0] ^ {N{sub}};

    addN #(.N(N)) addModule (a, adjusted_b, sub, out, cout);

endmodule

module addN #(
    parameter N = 32
) (
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic cin,
    output logic [N-1:0] sum,
    output logic cout
);

    logic [N:0] carries;
    assign carries[0] = cin;

    genvar i;
    generate
        for(i = 0; i < N; i++) begin
            add1 addModule (a[i], b[i], carries[i], sum[i], carries[i + 1]);
        end
    endgenerate

    assign cout = carries[N];
endmodule

module add1 (
    input logic a,
    input logic b,
    input logic cin,
    output logic sum,
    output logic cout
);

	logic a_plus_b;
	assign a_plus_b = a ^ b;

    logic carry;
    assign carry = a & b;
    logic a_plus_b_plus_carry;
    assign a_plus_b_plus_carry = a_plus_b ^ cin;
    logic carry_carry;
    assign carry_carry = carry | (a_plus_b & cin);

    assign sum = a_plus_b_plus_carry;
    assign cout = carry_carry;
endmodule