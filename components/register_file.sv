`default_nettype none
`timescale 1ns/1ps

module register_file(
  rst, clk,
  wr_ena, wr_addr, wr_data,
  rd_addr0, rd_data0,
  rd_addr1, rd_data1
);
// Not parametrizing, these widths are defined by the RISC-V Spec.

input wire clk, rst;

// Write channel:
input wire wr_ena;
input wire [4:0] wr_addr;
input wire [31:0] wr_data;

// Two read channels:
input wire [4:0] rd_addr0, rd_addr1;
output logic [31:0] rd_data0, rd_data1;

logic [31:0] x00; 
always_comb x00 = 32'd0; // ties x00 to ground

wire [31:0] x01, x02, x03, x04, x05, x06, x07, x08, x09, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31;
wire [31:0] wr_enas;

// create 31 registers
register #(.N(32), .RESET_VALUE(0)) register_x01 (.clk(clk), .rst(rst), .ena(wr_enas[01]), .d(wr_data), .q(x01));
register #(.N(32), .RESET_VALUE(0)) register_x02 (.clk(clk), .rst(rst), .ena(wr_enas[02]), .d(wr_data), .q(x02));
register #(.N(32), .RESET_VALUE(0)) register_x03 (.clk(clk), .rst(rst), .ena(wr_enas[03]), .d(wr_data), .q(x03));
register #(.N(32), .RESET_VALUE(0)) register_x04 (.clk(clk), .rst(rst), .ena(wr_enas[04]), .d(wr_data), .q(x04));
register #(.N(32), .RESET_VALUE(0)) register_x05 (.clk(clk), .rst(rst), .ena(wr_enas[05]), .d(wr_data), .q(x05));
register #(.N(32), .RESET_VALUE(0)) register_x06 (.clk(clk), .rst(rst), .ena(wr_enas[06]), .d(wr_data), .q(x06));
register #(.N(32), .RESET_VALUE(0)) register_x07 (.clk(clk), .rst(rst), .ena(wr_enas[07]), .d(wr_data), .q(x07));
register #(.N(32), .RESET_VALUE(0)) register_x08 (.clk(clk), .rst(rst), .ena(wr_enas[08]), .d(wr_data), .q(x08));
register #(.N(32), .RESET_VALUE(0)) register_x09 (.clk(clk), .rst(rst), .ena(wr_enas[09]), .d(wr_data), .q(x09));
register #(.N(32), .RESET_VALUE(0)) register_x10 (.clk(clk), .rst(rst), .ena(wr_enas[10]), .d(wr_data), .q(x10));
register #(.N(32), .RESET_VALUE(0)) register_x11 (.clk(clk), .rst(rst), .ena(wr_enas[11]), .d(wr_data), .q(x11));
register #(.N(32), .RESET_VALUE(0)) register_x12 (.clk(clk), .rst(rst), .ena(wr_enas[12]), .d(wr_data), .q(x12));
register #(.N(32), .RESET_VALUE(0)) register_x13 (.clk(clk), .rst(rst), .ena(wr_enas[13]), .d(wr_data), .q(x13));
register #(.N(32), .RESET_VALUE(0)) register_x14 (.clk(clk), .rst(rst), .ena(wr_enas[14]), .d(wr_data), .q(x14));
register #(.N(32), .RESET_VALUE(0)) register_x15 (.clk(clk), .rst(rst), .ena(wr_enas[15]), .d(wr_data), .q(x15));
register #(.N(32), .RESET_VALUE(0)) register_x16 (.clk(clk), .rst(rst), .ena(wr_enas[16]), .d(wr_data), .q(x16));
register #(.N(32), .RESET_VALUE(0)) register_x17 (.clk(clk), .rst(rst), .ena(wr_enas[17]), .d(wr_data), .q(x17));
register #(.N(32), .RESET_VALUE(0)) register_x18 (.clk(clk), .rst(rst), .ena(wr_enas[18]), .d(wr_data), .q(x18));
register #(.N(32), .RESET_VALUE(0)) register_x19 (.clk(clk), .rst(rst), .ena(wr_enas[19]), .d(wr_data), .q(x19));
register #(.N(32), .RESET_VALUE(0)) register_x20 (.clk(clk), .rst(rst), .ena(wr_enas[20]), .d(wr_data), .q(x20));
register #(.N(32), .RESET_VALUE(0)) register_x21 (.clk(clk), .rst(rst), .ena(wr_enas[21]), .d(wr_data), .q(x21));
register #(.N(32), .RESET_VALUE(0)) register_x22 (.clk(clk), .rst(rst), .ena(wr_enas[22]), .d(wr_data), .q(x22));
register #(.N(32), .RESET_VALUE(0)) register_x23 (.clk(clk), .rst(rst), .ena(wr_enas[23]), .d(wr_data), .q(x23));
register #(.N(32), .RESET_VALUE(0)) register_x24 (.clk(clk), .rst(rst), .ena(wr_enas[24]), .d(wr_data), .q(x24));
register #(.N(32), .RESET_VALUE(0)) register_x25 (.clk(clk), .rst(rst), .ena(wr_enas[25]), .d(wr_data), .q(x25));
register #(.N(32), .RESET_VALUE(0)) register_x26 (.clk(clk), .rst(rst), .ena(wr_enas[26]), .d(wr_data), .q(x26));
register #(.N(32), .RESET_VALUE(0)) register_x27 (.clk(clk), .rst(rst), .ena(wr_enas[27]), .d(wr_data), .q(x27));
register #(.N(32), .RESET_VALUE(0)) register_x28 (.clk(clk), .rst(rst), .ena(wr_enas[28]), .d(wr_data), .q(x28));
register #(.N(32), .RESET_VALUE(0)) register_x29 (.clk(clk), .rst(rst), .ena(wr_enas[29]), .d(wr_data), .q(x29));
register #(.N(32), .RESET_VALUE(0)) register_x30 (.clk(clk), .rst(rst), .ena(wr_enas[30]), .d(wr_data), .q(x30));
register #(.N(32), .RESET_VALUE(0)) register_x31 (.clk(clk), .rst(rst), .ena(wr_enas[31]), .d(wr_data), .q(x31));

// Create read ports

always_comb begin : read_mux0
  case(rd_addr0)
    5'd00 : rd_data0 = x00;
    5'd01 : rd_data0 = x01;
    5'd02 : rd_data0 = x02;
    5'd03 : rd_data0 = x03;
    5'd04 : rd_data0 = x04;
    5'd05 : rd_data0 = x05;
    5'd06 : rd_data0 = x06;
    5'd07 : rd_data0 = x07;
    5'd08 : rd_data0 = x08;
    5'd09 : rd_data0 = x09;
    5'd10 : rd_data0 = x10;
    5'd11 : rd_data0 = x11;
    5'd12 : rd_data0 = x12;
    5'd13 : rd_data0 = x13;
    5'd14 : rd_data0 = x14;
    5'd15 : rd_data0 = x15;
    5'd16 : rd_data0 = x16;
    5'd17 : rd_data0 = x17;
    5'd18 : rd_data0 = x18;
    5'd19 : rd_data0 = x19;
    5'd20 : rd_data0 = x20;
    5'd21 : rd_data0 = x21;
    5'd22 : rd_data0 = x22;
    5'd23 : rd_data0 = x23;
    5'd24 : rd_data0 = x24;
    5'd25 : rd_data0 = x25;
    5'd26 : rd_data0 = x26;
    5'd27 : rd_data0 = x27;
    5'd28 : rd_data0 = x28;
    5'd29 : rd_data0 = x29;
    5'd30 : rd_data0 = x30;
    5'd31 : rd_data0 = x31;
  endcase
end

always_comb begin : read_mux1
  case(rd_addr1)
    5'd00 : rd_data1 = x00;
    5'd01 : rd_data1 = x01;
    5'd02 : rd_data1 = x02;
    5'd03 : rd_data1 = x03;
    5'd04 : rd_data1 = x04;
    5'd05 : rd_data1 = x05;
    5'd06 : rd_data1 = x06;
    5'd07 : rd_data1 = x07;
    5'd08 : rd_data1 = x08;
    5'd09 : rd_data1 = x09;
    5'd10 : rd_data1 = x10;
    5'd11 : rd_data1 = x11;
    5'd12 : rd_data1 = x12;
    5'd13 : rd_data1 = x13;
    5'd14 : rd_data1 = x14;
    5'd15 : rd_data1 = x15;
    5'd16 : rd_data1 = x16;
    5'd17 : rd_data1 = x17;
    5'd18 : rd_data1 = x18;
    5'd19 : rd_data1 = x19;
    5'd20 : rd_data1 = x20;
    5'd21 : rd_data1 = x21;
    5'd22 : rd_data1 = x22;
    5'd23 : rd_data1 = x23;
    5'd24 : rd_data1 = x24;
    5'd25 : rd_data1 = x25;
    5'd26 : rd_data1 = x26;
    5'd27 : rd_data1 = x27;
    5'd28 : rd_data1 = x28;
    5'd29 : rd_data1 = x29;
    5'd30 : rd_data1 = x30;
    5'd31 : rd_data1 = x31;
  endcase
end


`define STRUCTURAL_DECODER
`ifdef STRUCTURAL_DECODER
decoder_5_to_32 WR_ENA_DECODER(.ena(wr_ena), .in(wr_addr), .out(wr_enas));
`endif

// Aliases (helpful for debugging assembly);
`ifdef SIMULATION
logic [31:0] ra, sp, gp, tp, t0, t1, t2, s0, fp, s1, a0, a1, a2, a3, a4, a5, 
  a6, a7, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, t3, t4, t5, t6;
always_comb begin : REGISTER_ALIASES
  ra = x01; // Return Address
  sp = x02; // Stack Pointer
  gp = x03; // Global Pointer
  tp = x04; // Thread Pointer
  fp = x08; // Frame Pointer
  s0 = x08; // Saved Registers - must be preserved by called functions.
  s1 = x09; 
  s2 = x18;
  s3 = x19;
  s4 = x20;
  s5 = x21;
  s6 = x22;
  s7 = x23;
  s8 = x24;
  s9 = x25;
  s10 = x26;
  s11 = x27;
  t0 = x05; // Temporary values (can be changed by called functions).
  t1 = x06;
  t2 = x07;
  t3 = x28;
  t4 = x29;
  t5 = x30;
  t6 = x31;
  a0 = x10;
  a1 = x11;
  a2 = x12;
  a3 = x13;
  a4 = x14;
  a5 = x15;
  a6 = x16;
  a7 = x17;
end

function void print_state();
  $display("|---------------------------------------|");
  $display("| Register File State                   |");
  $display("|---------------------------------------|");
  $display("| %12s = 0x%8h (%10d)|", "x00, zero", x00, x00);
  $display("| %12s = 0x%8h (%10d)|", "x01, ra", x01, x01);
  $display("| %12s = 0x%8h (%10d)|", "x02, sp", x02, x02);
  $display("| %12s = 0x%8h (%10d)|", "x03, gp", x03, x03);
  $display("| %12s = 0x%8h (%10d)|", "x04, tp", x04, x04);
  $display("| %12s = 0x%8h (%10d)|", "x05, t0", x05, x05);
  $display("| %12s = 0x%8h (%10d)|", "x06, t1", x06, x06);
  $display("| %12s = 0x%8h (%10d)|", "x07, t2", x07, x07);
  $display("| %12s = 0x%8h (%10d)|", "x08, s0", x08, x08);
  $display("| %12s = 0x%8h (%10d)|", "x09, s1", x09, x09);
  $display("| %12s = 0x%8h (%10d)|", "x10, a0", x10, x10);
  $display("| %12s = 0x%8h (%10d)|", "x11, a1", x11, x11);
  $display("| %12s = 0x%8h (%10d)|", "x12, a2", x12, x12);
  $display("| %12s = 0x%8h (%10d)|", "x13, a3", x13, x13);
  $display("| %12s = 0x%8h (%10d)|", "x14, a4", x14, x14);
  $display("| %12s = 0x%8h (%10d)|", "x15, a5", x15, x15);
  $display("| %12s = 0x%8h (%10d)|", "x16, a6", x16, x16);
  $display("| %12s = 0x%8h (%10d)|", "x17, a7", x17, x17);
  $display("| %12s = 0x%8h (%10d)|", "x18, s2", x18, x18); 
  $display("| %12s = 0x%8h (%10d)|", "x19, s3", x19, x19); 
  $display("| %12s = 0x%8h (%10d)|", "x20, s4", x20, x20); 
  $display("| %12s = 0x%8h (%10d)|", "x21, s5", x21, x21); 
  $display("| %12s = 0x%8h (%10d)|", "x22, s6", x22, x22); 
  $display("| %12s = 0x%8h (%10d)|", "x23, s7", x23, x23); 
  $display("| %12s = 0x%8h (%10d)|", "x24, s8", x24, x24); 
  $display("| %12s = 0x%8h (%10d)|", "x25, s9", x25, x25); 
  $display("| %12s = 0x%8h (%10d)|", "x26, s10", x26, x26); 
  $display("| %12s = 0x%8h (%10d)|", "x27, s11", x27, x27); 
  $display("| %12s = 0x%8h (%10d)|", "x28, t3", x28, x28); 
  $display("| %12s = 0x%8h (%10d)|", "x29, t4", x29, x29); 
  $display("| %12s = 0x%8h (%10d)|", "x30, t5", x30, x30); 
  $display("| %12s = 0x%8h (%10d)|", "x31, t6", x31, x31); 
  $display("|---------------------------------------|");
endfunction // print_state

/*
// TODO(avinash) - finish this task for more automated testing.
task dump_state(string file);
  int fd = $fopen("./register_file.txt", "w");
  $fdisplay(fd, "|---------------------------------------|");
  $fdisplay(fd, "| Register File State                   |");
  $fdisplay(fd, "|---------------------------------------|");
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x00, zero", x00, x00);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x01, ra", x01, x01);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x02, sp", x02, x02);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x03, gp", x03, x03);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x04, tp", x04, x04);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x05, t0", x05, x05);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x06, t1", x06, x06);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x07, t2", x07, x07);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x08, s0", x08, x08);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x09, s1", x09, x09);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x10, a0", x10, x10);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x11, a1", x11, x11);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x12, a2", x12, x12);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x13, a3", x13, x13);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x14, a4", x14, x14);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x15, a5", x15, x15);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x16, a6", x16, x16);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x17, a7", x17, x17);
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x18, s2", x18, x18); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x19, s3", x19, x19); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x20, s4", x20, x20); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x21, s5", x21, x21); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x22, s6", x22, x22); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x23, s7", x23, x23); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x24, s8", x24, x24); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x25, s9", x25, x25); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x26, s10", x26, x26); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x27, s11", x27, x27); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x28, t3", x28, x28); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x29, t4", x29, x29); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x30, t5", x30, x30); 
  $fdisplay(fd, "| %12s = 0x%8h (%10d)|", "x31, t6", x31, x31); 
  $fdisplay(fd, "|---------------------------------------|");
  $fclose(fd);
endtask
*/ 

`endif // SIMULATION
endmodule
