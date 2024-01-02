`include "brisc_pkg.svh"

module core_top
  import brisc_pkg::*;
(
    input logic clk,
    input logic reset
);

  core brisc_core (
      .clk(clk),
      .reset(reset)
  );
endmodule
