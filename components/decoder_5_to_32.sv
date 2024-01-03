`timescale 1ns/1ps
`default_nettype none

module decoder_5_to_32(ena, in, out);

input wire ena;
input wire [4:0] in;
output logic [31:0] out;

wire[1:0] decoder0_out;

decoder_1_to_2 decoder0 (.ena(ena), .in(in[4]), .out(decoder0_out));
decoder_4_to_16 decoder1 (.ena(decoder0_out[0]), .in(in[3:0]), .out(out[15:0]));
decoder_4_to_16 decoder2 (.ena(decoder0_out[1]), .in(in[3:0]), .out(out[31:16]));

endmodule
