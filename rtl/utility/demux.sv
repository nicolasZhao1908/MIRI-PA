`ifndef DEMUX_SV
`define DEMUX_SV

module demux_test (
    input logic [1 - 1:0] inp,
    input logic [7 - 1:0] ctrl,
    output logic [1 - 1:0] out[128]
);

  demux #(
      .CTRL(7)
  ) dm (
      .inp(inp),
      .ctrl(ctrl),
      .out(out)
  );
endmodule


module demux #(
    parameter integer unsigned CTRL = 2,
    parameter integer unsigned DATA_WIDTH = 1
) (
    input logic [DATA_WIDTH - 1:0] inp,
    input logic [CTRL - 1:0] ctrl,
    output logic [DATA_WIDTH - 1:0] out[2 ** CTRL]
);

  genvar i;

  generate
    for (i = 0; i < 2 ** CTRL; i = i + 1) begin : g_dm_out
      assign out[i] = ctrl == i ? inp : {DATA_WIDTH{1'b0}};
    end
  endgenerate

endmodule

`endif
