`timescale 1ns/1ps
`default_nettype none

module decoder_1_to_2(ena, in, out);

input wire ena;
input wire in;
output logic [1:0] out;

always_comb out = ena ? (in ? 2'b10 : 2'b01): 2'b00;

endmodule
