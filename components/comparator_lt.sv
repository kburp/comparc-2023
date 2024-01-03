`default_nettype none

module comparator_lt(a, b, out);

parameter N = 32;
input wire signed [N-1:0] a, b;
output logic out;

// Using only *structural* combinational logic (or instantiated modules that 
// only consist of structural combination logic), make a module that outputs 
// high if a < b.

wire [N-1:0] difference;
wire c_out;

adder_n #(.N(N)) ADDER (.a(a), .b(~b), .c_in(1'b1), .sum(difference), .c_out(c_out));

always_comb begin
if (a[N-1] & ~b[N-1])
  out = 1'b1;
else if(~a[N-1] & b[N-1])
  out = 1'b0;
else
  out = difference[N-1];
end

endmodule
