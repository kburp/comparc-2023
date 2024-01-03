`timescale 1ns/1ps
`default_nettype none

`include "alu_types.sv"
`include "memory_access.sv"
`include "memory_exceptions.sv"
`include "rv32_common.sv"
`include "memory_map.sv" 


module rv32i_multicycle_core(
  clk, rst, ena,
  mem_addr, mem_rd_data, mem_wr_data, mem_wr_ena,
  mem_access, mem_exception,
  PC, instructions_completed, instruction_done
);

parameter PC_START_ADDRESS = {MMU_BANK_INST, 28'h0};

// Standard control signals.
input  wire clk, rst, ena; // <- worry about implementing the ena signal last.
output logic instruction_done; // Should be high for one clock cycle when finishing an instruction (e.g. during the writeback state).

// Memory interface.
output logic [31:0] mem_addr, mem_wr_data;
input   wire [31:0] mem_rd_data;
output mem_access_t mem_access;
input mem_exception_mask_t mem_exception;
output logic mem_wr_ena;

// Program Counter
output wire [31:0] PC;
output logic [31:0] instructions_completed; // TODO(student) - increment this by one whenever an instruction is complete.
logic [31:0] PC_old;
logic PC_ena, PC_old_ena;
logic [31:0] PC_next;

// Control Signals
// Decoder
logic [6:0] op;
logic [2:0] funct3;
logic [6:0] funct7;
logic rtype, itype, ltype, stype, btype, jtype;
enum logic [2:0] {IMM_SRC_ITYPE, IMM_SRC_STYPE, IMM_SRC_BTYPE, IMM_SRC_JTYPE, IMM_SRC_UTYPE} immediate_src;
logic [31:0] extended_immediate;

// R-file Control Signals
logic [4:0] rd, rs1, rs2;
wire [31:0] reg_data1, reg_data2;
logic reg_write;
logic [31:0] rfile_wr_data;
wire [31:0] reg_A, reg_B;

// ALU Control Signals
enum logic [1:0] {ALU_SRC_A_PC, ALU_SRC_A_RF, ALU_SRC_A_OLD_PC, ALU_SRC_A_ZERO} 
  alu_src_a;
enum logic [1:0] {ALU_SRC_B_RF, ALU_SRC_B_IMM, ALU_SRC_B_4, ALU_SRC_B_ZERO} 
  alu_src_b;
logic [31:0] src_a, src_b;
wire [31:0] alu_result;
alu_control_t alu_control, ri_alu_control;
wire overflow;
wire zero;
wire equal;

// Non-architectural Register Signals
logic IR_ena;
wire [31:0] IR; // Instruction Register (current instruction)
logic ALU_ena;
logic [31:0] alu_last; // Not a descriptive name, but this is what it's called in the text.
logic mem_data_ena;
logic [31:0] mem_data;
enum logic {MEM_SRC_PC, MEM_SRC_RESULT} mem_src;
enum logic [1:0] {RESULT_SRC_ALU, RESULT_SRC_MEM_DATA, RESULT_SRC_ALU_LAST} result_src; 
logic [31:0] result;

// Program Counter Register
register #(.N(32), .RESET_VALUE(PC_START_ADDRESS)) PC_REGISTER (
  .clk(clk), .rst(rst), .ena(PC_ena), .d(PC_next), .q(PC)
);

// Register file
register_file REGISTER_FILE(
  .clk(clk), .rst(rst),
  .wr_ena(reg_write), .wr_addr(rd), .wr_data(rfile_wr_data),
  .rd_addr0(rs1), .rd_addr1(rs2),
  .rd_data0(reg_data1), .rd_data1(reg_data2)
);

task print_rfile();
  REGISTER_FILE.print_state();
endtask

// Non-architecture register: save register read data for future cycles.
register #(.N(32)) REGISTER_A (.clk(clk), .rst(rst), .ena(1'b1), .d(reg_data1), .q(reg_A));
register #(.N(32)) REGISTER_B (.clk(clk), .rst(rst), .ena(1'b1), .d(reg_data2), .q(reg_B));
always_comb mem_wr_data = reg_B; // RISC-V always stores data from this location.

// ALU and related control signals - use the behavioral one if you need to.
alu ALU (
  .a(src_a), .b(src_b), .result(alu_result),
  .control(alu_control),
  .overflow(overflow), .zero(zero), .equal(equal)
);

// ALU register
always_ff @(posedge clk) begin : alu_registers
  if(rst) begin
    alu_last <= 0;
  end else begin
    alu_last <= alu_result;
  end
end

enum logic [3:0] {
  S_FETCH = 0,
  S_DECODE = 1,
  S_EXEC_I = 2,
  S_EXEC_R = 3,
  S_WRITEBACK = 4,
  S_MEM_ADDR = 5,
  S_MEM_READ = 6,
  S_MEM_WRITEBACK = 7,
  S_MEM_WRITE = 8,
  S_BRANCH = 10,
  S_JALR = 11,
  S_JAL = 12,
  S_J_WRITEBACK = 13,
  S_ERROR = 4'b1111
  } state, next_state;

// Main finite state machine
always_ff @(posedge clk) begin
  if (rst) begin
    state <= S_FETCH;
  end else begin
    // Only I-type for now
    case(state)
      S_FETCH : state <= S_DECODE;
      S_DECODE : begin
        case(op)
          OP_ITYPE : state <= S_EXEC_I;
          OP_RTYPE : state <= S_EXEC_R;
          OP_BTYPE : state <= S_BRANCH;
          OP_JALR : state <= S_JALR;
          OP_JAL : state <= S_JAL;
          OP_LTYPE : state <= S_MEM_ADDR;
          OP_STYPE : state <= S_MEM_ADDR;
          default : state <= S_ERROR;
        endcase
      end
      S_EXEC_I, S_EXEC_R : state <= S_WRITEBACK;
      S_WRITEBACK, S_MEM_WRITEBACK : state <= S_FETCH;
      S_MEM_ADDR : begin
        case(op)
          OP_LTYPE: state <= S_MEM_READ;
          OP_STYPE: state <= S_MEM_WRITE;
        endcase
      end
      S_MEM_READ : state <= S_MEM_WRITEBACK;
      S_BRANCH : state <= S_FETCH;
      S_JALR, S_JAL : state <= S_J_WRITEBACK;
      S_J_WRITEBACK : state <= S_FETCH;
      S_MEM_WRITE : state <= S_FETCH;
      default : state <= S_ERROR;
    endcase
  end
end

// Instruction register
register #(.N(32)) register_IR (.clk(clk), .rst(rst), .ena(IR_ena), .d(mem_rd_data), .q(IR));

// Define program counter and memory control signals
always_comb begin : memory_control_signals
  mem_access = MEM_ACCESS_WORD;
  mem_wr_ena = state == S_MEM_WRITE;
  case(state)
    S_MEM_READ, S_MEM_WRITE : mem_data_ena = 1;
    default : mem_data_ena = 0;
  endcase

  IR_ena = (state == S_FETCH);
  case(state)
    S_FETCH : begin
      PC_ena = 1;
      PC_next = alu_result;
    end
    S_BRANCH : begin
      case(funct3)
        FUNCT3_BEQ : PC_ena = equal;
        FUNCT3_BNE : PC_ena = ~equal;
        FUNCT3_BLT : PC_ena = alu_result[0];
        FUNCT3_BGE : PC_ena = ~alu_result[0];
        FUNCT3_BLTU : PC_ena = alu_result[0];
        FUNCT3_BGEU : PC_ena = ~alu_result[0];
      endcase
      PC_next = alu_last;
    end
    S_JALR, S_JAL : begin
      PC_ena = 1;
      PC_next = alu_result;
    end
    default : begin
      PC_ena = 0;
      PC_next = PC;
    end
  endcase

  case(state)
    S_FETCH : mem_addr = PC;
    S_MEM_READ, S_MEM_WRITE : mem_addr = alu_last;
    default : mem_addr = PC;
  endcase
end

always_ff @(posedge clk) begin
  if (rst) mem_data <= 0;
  else begin 
    if(mem_data_ena) mem_data <= mem_rd_data;
  end
end

// Register for saving previous PC
always_ff @(posedge clk) begin
  if (rst) PC_old <= 0;
  else begin
    if (PC_ena) PC_old <= PC;
  end
end

// ALU control

always_comb begin : alu_controller
  case(state)
    S_FETCH : begin
      alu_src_a = ALU_SRC_A_PC;
      alu_src_b = ALU_SRC_B_4;
      alu_control = ALU_ADD;
    end
    S_DECODE : begin
      alu_src_a = ALU_SRC_A_OLD_PC;
      alu_src_b = ALU_SRC_B_IMM;
      alu_control = ALU_ADD;
    end
    S_EXEC_I : begin
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_IMM;
      case(funct3)
        FUNCT3_ADD : alu_control = ALU_ADD;
        FUNCT3_SLL : alu_control = ALU_SLL;
        FUNCT3_SLT : alu_control = ALU_SLT;
        FUNCT3_SLTU : alu_control = ALU_SLTU;
        FUNCT3_XOR : alu_control = ALU_XOR;
        FUNCT3_SHIFT_RIGHT : begin
          if(funct7 == 7'b0100000) alu_control = ALU_SRA;
          else alu_control = ALU_SRL;
        end
        FUNCT3_OR : alu_control = ALU_OR;
        FUNCT3_AND : alu_control = ALU_AND;
      endcase
    end
    S_MEM_ADDR : begin
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_IMM;
      alu_control = ALU_ADD;
    end
    S_EXEC_R : begin
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_RF;
      case(funct3)
        FUNCT3_ADD : begin
          if(funct7 == 7'b0100000) alu_control = ALU_SUB;
          else alu_control = ALU_ADD;
        end
        FUNCT3_SLL : alu_control = ALU_SLL;
        FUNCT3_SLT : alu_control = ALU_SLT;
        FUNCT3_SLTU : alu_control = ALU_SLTU;
        FUNCT3_XOR : alu_control = ALU_XOR;
        FUNCT3_SHIFT_RIGHT : begin
          if(funct7 == 7'b0100000) alu_control = ALU_SRA;
          else alu_control = ALU_SRL;
        end
        FUNCT3_OR : alu_control = ALU_OR;
        FUNCT3_AND : alu_control = ALU_AND;
      endcase
    end
    S_BRANCH : begin
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_RF;
      case(funct3)
        FUNCT3_BGEU, FUNCT3_BLTU : alu_control = ALU_SLTU;
        default: alu_control = ALU_SLT;
      endcase
    end
    S_JAL : begin
      alu_src_a = ALU_SRC_A_OLD_PC;
      alu_src_b = ALU_SRC_B_IMM;
      alu_control = ALU_ADD;
    end
    S_JALR : begin
      alu_src_a = ALU_SRC_A_RF;
      alu_src_b = ALU_SRC_B_IMM;
      alu_control = ALU_ADD;
    end
    default : begin
      alu_src_a = ALU_SRC_A_PC;
      alu_src_b = ALU_SRC_B_ZERO;
      alu_control = ALU_ADD;
    end
  endcase
end

always_comb begin : ALU_MUX_A
  case (alu_src_a)
    ALU_SRC_A_PC : src_a = PC;
    ALU_SRC_A_OLD_PC : src_a = PC_old;
    ALU_SRC_A_RF : src_a = reg_data1;
    default : src_a = 0;
  endcase
end

always_comb begin : ALU_MUX_B
  case (alu_src_b)
    ALU_SRC_B_4 : src_b = 32'd4;
    ALU_SRC_B_RF : src_b = reg_data2;
    ALU_SRC_B_IMM : src_b = extended_immediate;
    default : src_b = 0;
  endcase
end

// Decode logic

logic [11:0] imm12;
always_comb begin : rv32i_decoder
  op = IR[6:0];
  rd = IR[11:7];
  rs1 = IR[19:15];
  rs2 = IR[24:20];
  funct3 = IR[14:12];
  funct7 = IR[31:25];
  imm12 = IR[31:20];

  case(op)
    OP_ITYPE : begin
      if(funct3 == FUNCT3_SHIFT_RIGHT | funct3 == FUNCT3_SLL) begin
        extended_immediate = {27'b0, IR[24:20]};
      end else begin
        extended_immediate = {{5'd20{IR[31]}}, IR[31:20]}; 
      end
    end
    OP_LTYPE : extended_immediate = {{5'd20{IR[31]}}, IR[31:20]};
    OP_STYPE : extended_immediate = {{20{IR[31]}}, IR[31:25],IR[11:7]};
    OP_BTYPE : extended_immediate = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
    OP_JAL : extended_immediate = {{12{IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0};
    OP_LUI : extended_immediate = {IR[31:12], 12'b0};
  endcase
end

// Writeback logic

always_comb begin : writeback_controller
  case(state)
  S_WRITEBACK : begin
    reg_write = 1;
    rfile_wr_data = alu_last;
  end
  S_J_WRITEBACK : begin
    reg_write = 1;
    rfile_wr_data = PC_old;
  end
  S_MEM_WRITEBACK : begin
    reg_write = 1;
    rfile_wr_data = mem_data;
  end
  default : begin
    reg_write = 0;
    rfile_wr_data = 0;
  end
  endcase
end

endmodule
