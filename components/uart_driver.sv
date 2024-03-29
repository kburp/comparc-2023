`timescale 1ns/1ps
`default_nettype none

/*
Written for the FT2232HQ on the CMod A7 board.
- UART Interface supports 7/8 bit data, 1/2 stop bits, and Odd/Even/Mark/Space/No Parity.
- defaulting to 8N1.
- See FTDI AN 120 Aliasing VCP Baud Rates for details, but salient points for valid baudrates.
  - links should be within 3% of the spec'd clock
  - #Mhz basedivided by n + (0.125, 0.25, 0.375, 0.625, 0.5, 0.75, 0.875)
  - TL;DR a few clock cycles won't matter too much if clk > 3*BAUDRATE.
  TODO(avinash)
    - fix ready/valid to be axi4-lite compliant.
*/

module uart_driver(
  clk, rst,
  rx_data, rx_valid,
  tx_data, tx_valid, tx_ready,
  uart_tx, uart_rx
);


// These are set for the CMod A7, modify for different clocks/baudrates!
parameter CLK_HZ = 12_000_000;
parameter BAUDRATE = 115200;
// Depth of synchronizer (measure of MTBF).
parameter SYNC_DEPTH = 3;
// A derived parameter.
localparam OVERSAMPLE = CLK_HZ/BAUDRATE;


// 8N1 - probably shouldn't change this.
parameter DATA_BITS = 8;
parameter PARITY = 0;
parameter STOP_BITS = 1;

input wire clk, rst;
input wire uart_rx;
output logic uart_tx;

input wire [DATA_BITS-1:0] tx_data;
output logic [DATA_BITS-1:0] rx_data;
input wire tx_valid;
output logic rx_valid, tx_ready;

logic [SYNC_DEPTH-1:0] input_buffer;
logic uart_rx_synced;
always_comb uart_rx_synced = input_buffer[SYNC_DEPTH-1];
always_ff@(posedge clk) begin : input_synchronizer
  if(rst) begin
    input_buffer <= -1;
  end else begin
    input_buffer[0] <= uart_rx;
    input_buffer[SYNC_DEPTH-1:1] <= input_buffer[SYNC_DEPTH-2:0];
  end
end

enum logic [1:0] {
  S_IDLE = 0,
  S_START,
  S_DATA,
  S_STOP
} tx_state, rx_state;

// tx state machine
logic [$clog2(OVERSAMPLE)-1:0] baud_counter;
logic [2:0] bit_counter;
logic [7:0] tx_buffer;
always_ff @(posedge clk) begin : tx_fsm
  if(rst) begin
    tx_state <= S_IDLE;
    baud_counter <= 0;
    bit_counter <= 3'd7;
    tx_buffer <= 8'b0;
  end else begin
    case (tx_state)
      S_IDLE : begin
        if(tx_valid) begin
          tx_state <= S_START;
          tx_buffer <= tx_data;
        end
      end
      S_START : begin
        if (baud_counter >= OVERSAMPLE) begin
          tx_state <= S_DATA;
          baud_counter <= 0;
          bit_counter <= 3'd7;
        end else begin
          baud_counter <= baud_counter + 1;
        end
      end
      S_DATA : begin
        if (baud_counter >= OVERSAMPLE) begin
          baud_counter <= 0;
          tx_buffer[6:0] <= tx_buffer[7:1];
          tx_buffer[7] <= 1'b0;
          if (bit_counter == 0) begin
            tx_state <= S_STOP;
          end else begin
            bit_counter <= bit_counter - 1;
          end
        end else begin
          baud_counter <= baud_counter + 1;
        end
      end
      S_STOP : begin
        if (baud_counter >= OVERSAMPLE) begin
          tx_state <= S_IDLE;
          baud_counter <= 0;
        end else begin
          baud_counter <= baud_counter + 1;
        end
      end
      default : begin
        tx_state <= S_IDLE;
      end
    endcase
  end
end

always_comb begin
  case(tx_state)
    S_IDLE : tx_ready = 1'b1;
    default : tx_ready = 1'b0;
  endcase

  case(tx_state)
    S_IDLE : uart_tx = 1'b1;
    S_START : uart_tx = 1'b0;
    S_DATA : uart_tx = tx_buffer[0];
    S_STOP : uart_tx = 1'b1;
  endcase
end

// Rx FSM

logic rx_waiting;
logic rx_sample;
logic [2:0] rx_bit_counter;
logic [$clog2(OVERSAMPLE)-1:0] rx_baud_counter;
logic [7:0] rx_buffer;

always_ff @(posedge clk) begin
  if(rst) begin
    rx_baud_counter <= 0;
  end else begin
    case(rx_state)
      S_IDLE : begin
        if(~uart_rx_synced) begin
          rx_baud_counter <= 0;
        end
      end
      default : begin
        if(~rx_waiting) begin
          rx_baud_counter <= 0;
        end else begin
          rx_baud_counter <= rx_baud_counter + 1;
        end
      end
    endcase
  end
end

always_comb begin
  case(rx_state)
    S_IDLE : begin
      rx_waiting = 1'b0;
      rx_sample = 1'b0;
    end
    default : begin
      rx_waiting = rx_baud_counter < OVERSAMPLE;
      rx_sample = (rx_baud_counter == OVERSAMPLE/2);
    end
  endcase
end


always_ff @(posedge clk) begin : rx_fsm
  if(rst) begin
    rx_state <= S_IDLE;
    rx_bit_counter <= 0;
    rx_valid <= 0;
  end else begin
    case(rx_state)
      S_IDLE : begin
        if(~uart_rx_synced) begin
          rx_valid <= 0;
          rx_state <= S_START;
          rx_bit_counter <= 0;
        end
      end
      S_START : begin
        if(~rx_waiting) begin
          rx_state <= S_DATA;
        end
      end
      S_DATA : begin
        if(rx_sample) begin
          rx_buffer[rx_bit_counter] <= uart_rx_synced;
          if(rx_bit_counter == 3'd7) begin
            rx_state <= S_STOP;
          end else begin
            rx_bit_counter <= rx_bit_counter + 1;
          end
        end
      end
      S_STOP : begin
        rx_data <= rx_buffer;
        rx_valid <= 1;
        if(~rx_waiting) begin
          rx_state <= S_IDLE;
        end
      end
    endcase
  end
end

endmodule
