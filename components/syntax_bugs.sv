module syntax_bugs;


wire x, clk;
always_comb begin
  x <= 1;
end

logic [3:0] y;
always_comb begin
  y = 3832;
end

logic q;
always_ff begin
 q = ~q;
end

endmodule