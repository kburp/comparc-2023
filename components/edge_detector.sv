module edge_detector(clk, rst, in, positive_edge, negative_edge);

input wire clk, rst, in;
output logic positive_edge, negative_edge;

logic q;

always_ff @(posedge clk) begin
    if (rst)
        q <= 0;
    else 
        q <= in;
end

always_comb begin
    positive_edge = in & ~q;
    negative_edge = ~in & q;
end

endmodule // edge_detector
