`include "brisc_pkg.svh"

module ram
  import brisc_pkg::ADDRESS_BITS, brisc_pkg::MEM_REQ_DELAY, brisc_pkg::MEM_RESP_DELAY;
(
    input logic clk,
    input logic req,
    input logic [ADDRESS_BITS-1:0] addr,
    output logic resp,
    output logic [31:0] data
);
  // TODO
  logic [31:0] ram[63];
  logic [ADDRESS_BITS-1:0] addr_bus;
  logic req_bus;


  initial begin
    data = '0;
    addr_bus = '0;
    resp = 0;
    req_bus = 0;
    $readmemh("ram.txt", ram);
  end

  shift_reg #(
      .WIDTH(ADDRESS_BITS),
      .N(MEM_REQ_DELAY)
  ) inp_addr (
    .clk(clk),
    .reset(1'b0),
    .enable(req),
    .data_in(addr),
    .data_out(addr_bus)
  );

  shift_reg #(
      .WIDTH(1),
      .N(MEM_REQ_DELAY)
  ) inp_req (
    .clk(clk),
    .reset(1'b0),
    .enable(req),
    .data_in(req),
    .data_out(req_bus)
  );

  shift_reg #(
      .WIDTH(32),
      .N(MEM_RESP_DELAY)
  ) out_data (
    .clk(clk),
    .reset(1'b0),
    .enable(req_bus),
    .data_in(ram[addr_bus[7:2]]),
    .data_out(data)
  );

  shift_reg #(
      .WIDTH(1),
      .N(MEM_RESP_DELAY)
  ) out_resp (
    .clk(clk),
    .reset(1'b0),
    .enable(req_bus),
    .data_in(req_bus),
    .data_out(resp)
  );


endmodule


// module ram
//   import brisc_pkg::ADDRESS_BITS, brisc_pkg::MEM_REQ_DELAY, brisc_pkg::MEM_RESP_DELAY;
// (
//     input logic clk,
//     input logic req,
//     input logic [ADDRESS_BITS-1:0] addr,
//     output logic resp,
//     output logic [31:0] data
// );
//   logic [31:0] ram[63];

//   logic [31:0] data_bus;
//   logic [ADDRESS_BITS-1:0] addr_bus;
//   logic req_bus;
//   logic [ADDRESS_BITS-1:0] in_addrs[MEM_REQ_DELAY];
//   logic in_reqs[MEM_REQ_DELAY];
//   logic [31:0] out_datas[MEM_RESP_DELAY];
//   logic out_resps[MEM_RESP_DELAY];

//   initial begin
//     resp = 0;
//     data = '0;
//     req_bus = 0;
//     data_bus = 0;
//     addr_bus = 0;
//     for (int unsigned i = 0; i < MEM_REQ_DELAY; ++i) begin
//       in_addrs[i] = '0;
//       in_reqs[i]  = '0;
//     end
//     for (int unsigned i = 0; i < MEM_RESP_DELAY; ++i) begin
//       out_datas[i] = '0;
//       out_resps[i] = '0;
//     end

//     $readmemh("ram.txt", ram);
//   end

//   genvar i;
//   // MEM REQUEST DELAY of 5 cycles
//   // Artificial delays w/ ffs
//   generate
//     for (i = 0; i < MEM_REQ_DELAY; ++i) begin : g_in_req_delay
//       ff #(
//           .WIDTH(1)
//       ) req_i (
//           .clk(clk),
//           .enable(i == 0 ? req : !in_reqs[i]),
//           .reset(in_reqs[i]),
//           .inp(i == 0 ? req : in_reqs[i-1]),
//           .out(in_reqs[i])
//       );
//     end
//   endgenerate
//   assign req_bus = in_reqs[MEM_RESP_DELAY-1];

//   // MEM REQUEST DELAY of 5 cycles
//   // Artificial delays w/ ffs
//   generate
//     for (i = 0; i < MEM_REQ_DELAY; ++i) begin : g_in_addr_delay
//       ff #(
//           .WIDTH(ADDRESS_BITS)
//       ) addr_i (
//           .clk(clk),
//           .enable(i == 0 ? req : !in_reqs[i]),
//           .reset(in_reqs[i]),
//           .inp(i == 0 ? addr : in_addrs[i-1]),
//           .out(in_addrs[i])
//       );
//     end
//   endgenerate
//   assign addr_bus = in_addrs[MEM_REQ_DELAY-1];


//   // MEM RESPONSE DELAY of 5 cycles
//   // Artificial delays w/ ffs
//   generate
//     for (i = 0; i < MEM_RESP_DELAY; ++i) begin : g_out_resp_delay
//       ff #(
//           .WIDTH(1)
//       ) resp_i (
//           .clk(clk),
//           .enable(i == 0 ? req_bus : !out_resps[i]),
//           .reset(out_resps[i]),
//           .inp(i == 0 ? req_bus : out_resps[i-1]),
//           .out(out_resps[i])
//       );
//     end
//   endgenerate
//   assign resp = out_resps[MEM_RESP_DELAY-1];

//   // MEM RESPONSE DELAY of 5 cycles
//   // Artificial delays w/ ffs
//   generate
//     for (i = 0; i < MEM_RESP_DELAY; ++i) begin : g_out_data_delay
//       ff #(
//           .WIDTH(ADDRESS_BITS)
//       ) data_i (
//           .clk(clk),
//           .enable(i == 0 ? req_bus : !out_resps[i]),
//           .reset(out_resps[i]),
//           .inp(i == 0 ? ram[addr_bus[7:2]] : out_datas[i-1]),
//           .out(out_datas[i])
//       );
//     end
//   endgenerate
//   assign data = out_datas[MEM_RESP_DELAY-1];

// endmodule
