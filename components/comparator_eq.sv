`default_nettype none

module comparator_eq(a, b, out);

parameter N = 32;
input wire signed [N-1:0] a, b;
output logic out;

// Using only *structural* combinational logic (or instantiated modules that 
// only consist of structural combination logic), make a module that outputs 
// high if a == b.
// If you use other modules, make sure to update the sources in the Makefile 
// appropriately!

logic [N-1:0] xor_out;

always_comb xor_out = a ^ b;

always_comb out = ~| xor_out;


endmodule
