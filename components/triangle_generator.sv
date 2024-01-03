`default_nettype none

// Generates "triangle" waves (counts from 0 to 2^N-1, then back down again)
// The triangle should increment/decrement only if the ena signal is high, and
// hold its value otherwise.
module triangle_generator(clk, rst, ena, out);

parameter N = 8;
input wire clk, rst, ena;
output logic [N-1:0] out;

// An example of defining a net for FSMs that can be very helpful.
typedef enum logic {COUNTING_UP, COUNTING_DOWN} state_t;
state_t state = COUNTING_UP;

logic [N-1:0] d, q, b_in;
logic c_out, comp_out;

register #(.N(N)) REGISTER (.clk(clk), .ena(ena), .rst(rst), .d(d), .q(q));
adder_n #(.N(N)) ADDER (.a(q), .b({N{1'b0}}), .c_in(1'b1), .sum(d), .c_out(c_out));

comparator_eq #(.N(N)) COMP (.a(q), .b({N{1'b1}}), .out(comp_out));

always_ff @(posedge clk) begin
    case (state)
        COUNTING_UP: begin
            out = q;
            if (comp_out)
                state = COUNTING_DOWN;
        end
        COUNTING_DOWN: begin
            out = ~q;
            if (comp_out)
                state = COUNTING_UP;

        end
    endcase
end

endmodule
