`default_nettype none

module sra(in,shamt,out);

parameter N=32;

input wire [N-1:0] in;
input wire [$clog2(N)-1:0] shamt;
output wire [N-1:0] out;

mux32 #(.N(N)) MUX0 (.in0(in[N-1:0]), .in1({{1 {in[N-1]}}, in[N-1:1]}), .in2({{2 {in[N-1]}}, in[N-1:2]}), .in3({{3 {in[N-1]}}, in[N-1:3]}), 
.in4({{4 {in[N-1]}}, in[N-1:4]}), .in5({{5 {in[N-1]}}, in[N-1:5]}), .in6({{6 {in[N-1]}}, in[N-1:6]}), .in7({{7 {in[N-1]}}, in[N-1:7]}), 
.in8({{8 {in[N-1]}}, in[N-1:8]}), .in9({{9 {in[N-1]}}, in[N-1:9]}), .in10({{10 {in[N-1]}}, in[N-1:10]}), .in11({{11 {in[N-1]}}, in[N-1:11]}), 
.in12({{12 {in[N-1]}}, in[N-1:12]}), .in13({{13 {in[N-1]}}, in[N-1:13]}), .in14({{14 {in[N-1]}}, in[N-1:14]}), .in15({{15 {in[N-1]}}, in[N-1:15]}), 
.in16({{16 {in[N-1]}}, in[N-1:16]}), .in17({{17 {in[N-1]}}, in[N-1:17]}), .in18({{18 {in[N-1]}}, in[N-1:18]}), .in19({{19 {in[N-1]}}, in[N-1:19]}), 
.in20({{20 {in[N-1]}}, in[N-1:20]}), .in21({{21 {in[N-1]}}, in[N-1:21]}), .in22({{22 {in[N-1]}}, in[N-1:22]}), .in23({{23 {in[N-1]}}, in[N-1:23]}), 
.in24({{24 {in[N-1]}}, in[N-1:24]}), .in25({{25 {in[N-1]}}, in[N-1:25]}), .in26({{26 {in[N-1]}}, in[N-1:26]}), .in27({{27 {in[N-1]}}, in[N-1:27]}), 
.in28({{28 {in[N-1]}}, in[N-1:28]}), .in29({{29 {in[N-1]}}, in[N-1:29]}), .in30({{30 {in[N-1]}}, in[N-1:30]}), .in31({{32 {in[N-1]}}}), 
.s(shamt), .out(out));

endmodule
