`timescale 1ns/1ps
`default_nettype none

module decoder_3_to_8(ena, in, out);

  input wire ena;
  input wire [2:0] in;
  output logic [7:0] out;

  wire[1:0] decoder0_out;

  decoder_1_to_2 decoder0 (.ena(ena), .in(in[2]), .out(decoder0_out));
  decoder_2_to_4 decoder1 (.ena(decoder0_out[0]), .in(in[1:0]), .out(out[3:0]));
  decoder_2_to_4 decoder2 (.ena(decoder0_out[1]), .in(in[1:0]), .out(out[7:4]));

endmodule
