`default_nettype none
`timescale 1ns/1ps

module test_uart_driver;

parameter CLK_HZ = 12_000_000;
localparam  CLK_PERIOD_NS = 1_000_000_000.0/CLK_HZ;
parameter BAUDRATE = 115200;
localparam BAUD_PERIOD_NS = 1_000_000_000.0/BAUDRATE;
parameter SYNC_DEPTH = 3;
parameter DATA_BITS = 8;
parameter PARITY = 0;
parameter STOP_BITS = 1;

// UUT IO
logic  clk;
logic  rst;
wire  uart_rx;
wire  uart_tx;
logic [DATA_BITS-1:0] tx_data;
wire [DATA_BITS-1:0] rx_data;
wire rx_valid, tx_ready;


uart_driver #(
  .CLK_HZ(CLK_HZ),
  .BAUDRATE(BAUDRATE),
  .SYNC_DEPTH(SYNC_DEPTH),
  .DATA_BITS(DATA_BITS),
  .PARITY(PARITY),
  .STOP_BITS(STOP_BITS)
) UUT (
  .clk(clk),
  .rst(rst),
  .uart_rx(uart_rx),
  .uart_tx(uart_tx),
  .rx_data(rx_data), 
  .rx_valid(rx_valid), 
  // loop back test - connect rx data to tx, send whenever it is valid.
  .tx_data(rx_data),
  .tx_valid(rx_valid),
  .tx_ready(tx_ready)
);


// Implement a "queue" that monitors what has been sent so that we can check that it was received in the correct order.
logic tb_tx_active = 0;
parameter L_BUFFER = 1000;
logic [7:0] sent_buffer[$:L_BUFFER];
integer buffer_wr_ptr = 0;
integer buffer_rd_ptr = 0;

function push_buffer(logic [7:0] in);
  sent_buffer.push_front(in);
  if(sent_buffer.size() > L_BUFFER) begin
    $display("!!! Critical Error, tester sent %d bytes without ack.", L_BUFFER);
  end
endfunction

function logic [7:0] pop_buffer();
if(sent_buffer.size()=== 0) begin
    $display("!!! Critical Error, UUT thought it received a byte but none have been sent.");
    $finish(1);
  end
  pop_buffer = sent_buffer.pop_back();
endfunction

uart_tester #(
  .CLK_HZ(CLK_HZ),
  .BAUDRATE(BAUDRATE),
  .SYNC_DEPTH(SYNC_DEPTH),
  .DATA_BITS(DATA_BITS),
  .PARITY(PARITY),
  .STOP_BITS(STOP_BITS),
  .VERBOSE(0) // Change to 1 to get more information.
) 
UART_TESTER (
  .clk(clk), .rst(rst), .uart_tx(uart_tx), .uart_rx(uart_rx)
);


logic [7:0] send_data;
integer offset_delay;

initial begin
  $dumpfile("uart_driver.fst");
  $dumpvars;

  clk = 0;
  rst = 1;
  send_data = 0;
  tx_data = 0;

  repeat (1) @(negedge clk);
  rst = 0;
  
  repeat (10) @(negedge clk);
  
  for(integer i = 0; i < 255; i = i + 1) begin
    send_data = 8'hFF -i[7:0];
    #1;
    offset_delay = $urandom %10_000 + 1_000;
    push_buffer(send_data);  
    UART_TESTER.send_byte(send_data, offset_delay);
  end

  offset_delay = $urandom %10_000 + 1_000;
  push_buffer(8'hAA);
  UART_TESTER.send_byte(8'hAA, 100);
  
  offset_delay = $urandom %10_000 + 1_000;
  push_buffer(8'h55);
  UART_TESTER.send_byte(8'h55, 100);
  


  repeat (10000) @(negedge clk);
  if(errors > 0) begin
    $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    $display("!!! Tests had %d errors, keep trying!", errors);
    $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    $finish(1);
  end else begin
    $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    $display("!!! ALL TESTS COMPLETED SUCCESSFULLY !!!");
    $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    $finish(0);
  end

end

always #(CLK_PERIOD_NS/2.0) clk = ~clk;

parameter MAX_ERRORS = 10;
integer errors = 0;

// RX monitor
logic [7:0] pending_byte;
always @(posedge rx_valid) begin
  if(~rst) begin
    #10;
    pending_byte = pop_buffer();
    $display("@%10t : UUT rx'd 0x%02x", $time, rx_data);
    if(pending_byte !== rx_data) begin
      $display("  ERROR: sent 0x%02x (%08b), rx'd 0x%02x (%08b)", pending_byte, pending_byte, rx_data, rx_data);
      errors = errors + 1;
      if(errors >= MAX_ERRORS) begin
        $display(" !!! CRITICAL !!! Found more than %d errors, quitting.", MAX_ERRORS);
        $finish;
      end
    end
  end
end

// TX monitor - tbh, it's easiest to just use another uart to test.
// `define LOOPBACK_TEST // Uncomment this when you have RX working and are ready to test TX.
`ifdef LOOPBACK_TEST

logic [DATA_BITS-1:0] loopback_rx_data, loopback_expected;
wire loopback_rx_data_valid;
uart_driver #(
  .BAUDRATE(BAUDRATE),
  .SYNC_DEPTH(SYNC_DEPTH),
  .DATA_BITS(DATA_BITS),
  .PARITY(PARITY),
  .STOP_BITS(STOP_BITS)
) LOOPBACK_UNIT (
  .clk(clk),
  .rst(rst),
  .uart_rx(uart_tx),
  // loop back test - connect rx data to tx, send whenever it is valid.
  .rx_data(loopback_rx_data), 
  .rx_valid(loopback_rx_data_valid), 
  .tx_data(8'd0),
  .tx_valid(1'b0)
);

always @(posedge rx_valid) begin
  loopback_expected = rx_data;
end

always @(posedge loopback_rx_data_valid) begin
  #1;
  $display("@%10t : LOOPBACK rx'd 0x%02x, expected 0x%02x", $time, loopback_rx_data, loopback_expected);
  if(loopback_expected !== loopback_rx_data) begin
    $display("  ERROR: loopback rx'd 0x%02x (%08b) instead of 0x%02x (%08b).", loopback_rx_data, loopback_rx_data, loopback_expected, loopback_expected);
    errors = errors + 1;
    if(errors >= MAX_ERRORS) begin
      $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      $display(" !!! Found more than %d errors, quitting.", MAX_ERRORS);
      $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      $finish(1);
    end
  end
end

`endif // LOOPBACK_TEST

endmodule
