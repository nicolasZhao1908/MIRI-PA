// TODO: Verible lint: for the filename adder.sv we should have a adder module in the file
// TODO: Maybe split into 2 files: adder.sv and subtractor.sv
module add_sub #(
    parameter integer unsigned N = 32
) (
    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic sub,
    output logic [N-1:0] out,
    output logic cout
);
  logic [N-1:0] adjusted_b;
  assign adjusted_b = b[N-1:0] ^ {N{sub}};

  adder_N #(
      .N(N)
  ) addModule (
      .a(a),
      .b(adjusted_b),
      .cin(sub),
      .sum(out),
      .cout(cout)
  );

endmodule

module adder_N #(
    parameter integer unsigned N = 32
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
    for (i = 0; i < N; i++) begin : g_adderN
      adder_1 addModule (
          .a(a[i]),
          .b(b[i]),
          .cin(carries[i]),
          .sum(sum[i]),
          .cout(carries[i+1])
      );
    end
  endgenerate

  assign cout = carries[N];
endmodule

module adder_1 (
    input  logic a,
    input  logic b,
    input  logic cin,
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
