module test_edge_detectors;

logic clk, rst, in;
wire  positive_edge, negative_edge;

edge_detector UUT(clk, rst, in, positive_edge, negative_edge);

logic [6:0] delay;

initial begin
  clk = 0; 
  rst = 1;
  in = 0;
  $dumpfile("edge_detector.fst");
  $dumpvars();

  repeat (2) @(negedge clk);
  rst = 0;

  for(int i = 0; i < 10; i = i + 1) begin
    delay = $random + 1;
    repeat (delay) @(negedge clk);
    in = ~in; // toggle input
  end
  repeat (10) @(posedge clk);
  $finish;

end

always #5 clk = ~clk; // clock signal

endmodule