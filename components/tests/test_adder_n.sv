`default_nettype none
module test_adder_n;

parameter N = 32;

int errors = 0;

logic [N-1:0] a, b;
logic c_in;
wire [N-1:0] sum;
wire c_out;

adder_n #(.N(N)) UUT(.a(a), .b(b), .c_in(c_in), .sum(sum), .c_out(c_out));

logic [N-1:0] correct_sum;
logic correct_c_out;

always_comb begin : solution_logic
    {correct_c_out, correct_sum} = a + b + c_in;
end

task print_io;
    $display("%8h %8h %b | %8h %b    %8h          %b", a, b, c_in, sum, c_out, correct_sum, correct_c_out);
endtask

initial begin
  $dumpfile("adder_n.fst");
  $dumpvars(0, UUT);

  $display("       a        b c |        s c  s(correct) c(correct)");

  // all zeros example
  a = 0;
  b = 0;
  c_in = 0;
  #1 print_io();

  // one zero example
  a = 0;
  b = 238467;
  c_in = 0;
  #1 print_io();

  // one zero and carry in example
  a = 12039;
  b = 0;
  c_in = 1;

  // overflow example
  a = 4294967291;
  b = 14;
  c_in = 1;
  #1 print_io();

  // random testing
  for (int i = 0; i < 20; i++) begin : random_testing
    a = $urandom();
    b = $urandom();
    c_in = $urandom_range(0, 1);
    #1 print_io();
  end

  // show success status
  if (errors !== 0) begin
    $display("---------------------------------------------------------------");
    $display("-- FAILURE                                                   --");
    $display("---------------------------------------------------------------");
    $display(" %d failures found, try again!", errors);
  end else begin
    $display("---------------------------------------------------------------");
    $display("-- SUCCESS                                                   --");
    $display("---------------------------------------------------------------");
  end
  $finish;

end

endmodule
