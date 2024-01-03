`default_nettype none

// Generates a Pulse Width Modulated signal.
// If ena is low the output should be low.
// If duty is zero the output should be zero.
// If duty is the max value (2^N-1) the output does not need ot be fully high 
//   (it's okay if it goes low for one cycle).
// Excel goal: find a way so that the output is steady high if duty = 2^N -1.

module pwm(clk, rst, ena, duty, out);

parameter N = 8;

input wire clk, rst;
input wire ena; // Enables the output.
input wire [N-1:0] duty; // The "duty cycle" input.
output logic out;

logic [N-1:0] d, q;
logic c_out;

register #(.N(N)) REGISTER (.clk(clk), .ena(ena), .rst(rst), .d(d), .q(q));

adder_n #(.N(N)) ADDER (.a({N{1'b0}}), .b(q), .c_in(1'b1), .sum(d), .c_out(c_out));

comparator_lt #(.N(N+1)) COMPARATOR (.a({1'b0, d}), .b({1'b0, duty}), .out(out));

endmodule
