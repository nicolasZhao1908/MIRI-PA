`ifndef DEMUX_SV
`define DEMUX_SV

module demux_test (
    input logic [1 - 1:0] in,
    input logic [7 - 1:0] ctrl,
    output logic [1 - 1:0] out[128]
);

  demux #(
      .CTRL(7)
  ) dm (
      .in(in),
      .ctrl(ctrl),
      .out(out)
  );
endmodule


module demux #(
    parameter integer CTRL = 2,
    parameter integer DATA_WIDTH = 1
) (
    input logic [DATA_WIDTH - 1:0] in,
    input logic [CTRL - 1:0] ctrl,
    output logic [DATA_WIDTH - 1:0] out[2 ** CTRL]
);

  genvar i;

  generate
    for (i = 0; i < 2 ** CTRL; i = i + 1) begin : g_dm_out
      assign out[i] = ctrl == i ? in : 1'b0;
    end
  endgenerate

endmodule

`endif
