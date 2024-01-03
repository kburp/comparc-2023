`timescale 1ns / 1ps

module test_pwm;

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
parameter PERIOD_US = 10; // Keep it small in the testbench 
parameter CLK_TICKS = CLK_HZ/1_000_000*PERIOD_US;
parameter PWM_WIDTH = 4;

logic clk, rst, ena;
logic [$clog2(CLK_TICKS)-1:0] ticks;
wire pwm_out;

logic [PWM_WIDTH-1:0] duty;
pwm #(.N(PWM_WIDTH)) PWM(
  .clk(clk), .rst(rst), .ena(ena), .duty(duty), .out(pwm_out)
);

always #(CLK_PERIOD_NS/2) clk = ~clk;

initial begin
  $dumpfile("pwm.fst");
  $dumpvars(0, PWM);

  rst = 1;
  ena = 1;
  clk = 0;
  ticks = CLK_TICKS;
  
  repeat (1) @(negedge clk);
  rst = 0;

  for(int i = 0; i < (2<<(PWM_WIDTH - 1)); i = i + 1) begin
    duty = i[PWM_WIDTH-1:0];
    repeat (2*(2<<PWM_WIDTH)*CLK_TICKS) @(posedge clk);
  end
  
  @(negedge clk);
  ena = 0;
  repeat (CLK_TICKS) @(posedge clk);
  $finish;
end

endmodule
