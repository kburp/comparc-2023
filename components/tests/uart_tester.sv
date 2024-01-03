`default_nettype none

module uart_tester(
  clk, rst,
  uart_tx, uart_rx
);

parameter CLK_HZ = 12_000_000;
localparam  CLK_PERIOD_NS = 1_000_000_000.0/CLK_HZ;
parameter BAUDRATE = 115200;
localparam BAUD_PERIOD_NS = 1_000_000_000.0/BAUDRATE;
parameter SYNC_DEPTH = 3;
parameter DATA_BITS = 8;
parameter PARITY = 0;
parameter STOP_BITS = 1;

parameter VERBOSE=0;

input wire clk, rst;
output logic uart_rx = 1;
input wire uart_tx;

task baudrate_delay;
  #(BAUD_PERIOD_NS);
endtask

logic sending_byte = 0;

task send_byte(logic [7:0] send_data, integer offset_delay);
  if(VERBOSE) begin
    $display("\n@%10t : tester sending byte 0x%02x after delay %d", $time, send_data, offset_delay);  
  end
  uart_rx = 1;
  #(offset_delay+1);
  baudrate_delay;
  sending_byte = 1;
  uart_rx = 0; // Start bit.
  baudrate_delay;
  for(integer i = 0; i < 8; i = i + 1) begin
    uart_rx = send_data[i]; // LSB first.
    baudrate_delay;
  end
  // Stop bit.
  uart_rx = 1;
  sending_byte = 0;
endtask

initial begin
  uart_rx = 1;
end

logic tx_sample_point = 0;
logic waiting_for_byte = 0;

task await_byte(output logic[7:0] result);
  result = 0;
  waiting_for_byte = 1;
  @(negedge uart_tx);
  #(BAUD_PERIOD_NS/2.0);
  for(integer i = 0; i < 8; i = i + 1) begin
    baudrate_delay;
    tx_sample_point = ~tx_sample_point;
    result[i] = uart_tx;
  end
  baudrate_delay;
  waiting_for_byte = 0;
endtask

endmodule