`ifndef DEMUX_SV
`define DEMUX_SV

module demux #(
    parameter CONTROL = 2,
    parameter DATA_WIDTH = 1
)
(
    input logic [DATA_WIDTH - 1:0] inp,
    input logic [CONTROL - 1:0] control,
    output logic [DATA_WIDTH - 1:0] out [2 ** CONTROL]
);

    genvar i;

    generate
      for (i = 0; i < 2  ** CONTROL; i = i + 1)  begin : dm_out
        assign out[i] = control==i ? inp : 1'b0;
      end
    endgenerate

endmodule

`endif