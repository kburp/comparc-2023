`timescale 1ns/1ps
`default_nettype none

module decoder_2_to_4(ena, in, out);

  input wire ena;
  input wire [1:0] in;
  output logic [3:0] out;

  wire [1:0] decoder0_out;

  decoder_1_to_2 decoder0 (.ena(ena), .in(in[1]), .out(decoder0_out));
  decoder_1_to_2 decoder1 (.ena(decoder0_out[0]), .in(in[0]), .out(out[1:0]));
  decoder_1_to_2 decoder2 (.ena(decoder0_out[1]), .in(in[0]), .out(out[3:2]));

endmodule
