`timescale 1ns/1ps
`default_nettype none

module decoder_4_to_16(ena, in, out);

input wire ena;
input wire [3:0] in;
output logic [15:0] out;

wire[1:0] decoder0_out;

decoder_1_to_2 decoder0 (.ena(ena), .in(in[3]), .out(decoder0_out));
decoder_3_to_8 decoder1 (.ena(decoder0_out[0]), .in(in[2:0]), .out(out[7:0]));
decoder_3_to_8 decoder2 (.ena(decoder0_out[1]), .in(in[2:0]), .out(out[15:8]));

endmodule
