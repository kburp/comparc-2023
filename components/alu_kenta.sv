`timescale 1ns/1ps
`default_nettype none

`include "alu_types.sv"

module alu(a, b, control, result, overflow, zero, equal);
parameter N = 32;

input wire signed [N-1:0] a, b;
input alu_control_t control;

output logic signed [N-1:0] result; // Result of the selected operation.

output logic overflow; // Is high if the result of an ADD or SUB wraps around the 32 bit boundary.
output logic zero;  // Is high if the result is ever all zeros.
output logic equal; // is high if a == b.

logic unsigned [N-1:0] unsigned_a, unsigned_b; // behavioural logic doesn't work right without setting signed or unsigned. Pretty much just for SLTU
logic carry_out;
logic [N-1:0] sum, difference, sll_res, srl_res, sra_res, slt, sltu, less_than;

mux16 #(.N(N)) CTRL_MUX (.in0(0), .in1(a & b), .in2(a | b), .in3(a ^ b), .in4(0), 
.in5(sll_res_real), .in6(srl_res_real), .in7(sra_res_real), .in8(sum), 
.in9(0), .in10(0), .in11(0), .in12(difference), 
.in13(slt), .in14(0), .in15(sltu), .s(control), .out(result));

adder_n #(.N(N)) ADDER (.a(a), .b(b), .c_in(0), .sum(sum), .c_out());
adder_n #(.N(N)) SUBTRACTOR (.a(a), .b(~b), .c_in(1'b1), .sum(difference), .c_out());

logic [N-1:0] sll_res_real, srl_res_real, sra_res_real;
sll #(.N(N)) LSHIFT (.in(a), .shamt(b[$clog2(N)-1:0]), .out(sll_res));
always_comb sll_res_real = |b[N-1:$clog2(N)] ? {N {1'b0}} : sll_res;
srl #(.N(N)) RSHIFT (.in(a), .shamt(b), .out(srl_res));
always_comb srl_res_real = |b[N-1:$clog2(N)] ? {N {1'b0}} : srl_res;
sra #(.N(N)) RSHIFTA (.in(a), .shamt(b), .out(sra_res));
always_comb sra_res_real = |b[N-1:$clog2(N)] ? {N {1'b0}} : sra_res;

comparator_lt #(.N(N)) COMP_LT (.a(a), .b(b), .out(less_than));
comparator_eq #(.N(N)) COMP_EQ (.a(a), .b(b), .out(equal));
comparator_eq #(.N(N)) ZERO_COMP (.a(result), .b({N {1'b0}}), .out(zero));

always_comb begin
  unsigned_a = a;
  unsigned_b = b;
  slt = { {(N-1){1'b0}}, less_than };
  sltu = { {(N-1){1'b0}}, unsigned_a < unsigned_b};

  case (control) 
    ALU_SLTU, ALU_SLT, ALU_SUB: begin
      overflow = (a[N-1] != b[N-1]) && (a[N-1] != difference[N-1]); 
    end
    ALU_ADD : begin
      overflow = (a[N-1] == b[N-1]) && (a[N-1] != sum[N-1]);
    end
    default: overflow = 0;
  endcase
end

endmodule
