/*
    New ALU test bench based on final_ALU_tb.v
    Updated to use iAluOp (4-bit) instead of iFunct3/iFunct7
*/

`timescale 1ns / 1ps

module new_alu_tb();
  // Inputs
  reg [31:0] iDataA;
  reg [31:0] iDataB;
  reg [3:0]  iAluOp;

  // Outputs
  wire [31:0] oData;
  wire        oZero;

  // Instantiate the Unit Under Test (UUT)
  // Note: ALU.v needs to be updated to match these ports
  ALU uut (
        .iDataA(iDataA),
        .iDataB(iDataB),
        .iAluOp(iAluOp), // New input
        .oData(oData),
        .oZero(oZero)
      );

  // Task for scannable output
  task check_result;
    input [8*20:1] op_name;
    input [31:0] expected;
    begin
      #10; // Wait for combinational logic
      if (oData === expected)
        $display("[PASS] %s | A:%h B:%h | Op:%b | Result:%h", op_name, iDataA, iDataB, iAluOp, oData);
      else
        $display("[FAIL] %s | A:%h B:%h | Op:%b | Result:%h (Exp:%h)", op_name, iDataA, iDataB, iAluOp, oData, expected);
    end
  endtask

  // ALU Operation Codes mapped from newalu.v
  localparam ADD  = 4'b0000;
  localparam SUB  = 4'b1000;
  localparam SLL  = 4'b0001;
  localparam SRL  = 4'b1001;
  localparam SRA  = 4'b1101;
  localparam SLT  = 4'b0010;
  localparam SLTU = 4'b0011;
  localparam XOR  = 4'b0100;
  localparam OR   = 4'b0110;
  localparam AND  = 4'b0111;
  // Branch ops from newalu.v (map to SUB logic generally, but strict ALU output depends on implementation)
  // For now, testing the arithmetic/logic operations as defined in original TB

  initial
  begin
    $dumpfile("new_alu_sim.vcd");
    $dumpvars(0, new_alu_tb);

    $display("--- Starting Comprehensive New ALU Tests ---");

    // --- Test 1: Addition ---
    iDataA = 32'd10;
    iDataB = 32'd5;
    iAluOp = ADD;
    check_result("ADD", 32'd15);

    // --- Test 2: Subtraction ---
    iDataA = 32'd20;
    iDataB = 32'd7;
    iAluOp = SUB;
    check_result("SUB", 32'd13);

    // --- Test 3: SLL (Shift Left Logical) ---
    iDataA = 32'h0000_0001;
    iDataB = 32'd4;
    iAluOp = SLL;
    check_result("SLL", 32'h0000_0010);

    // --- Test 4: SRL (Shift Right Logical) ---
    iDataA = 32'h8000_0000;
    iDataB = 32'd1;
    iAluOp = SRL;
    check_result("SRL", 32'h4000_0000);

    // --- Test 5: SRA (Shift Right Arithmetic) ---
    iDataA = 32'h8000_0000;
    iDataB = 32'd1;
    iAluOp = SRA;
    check_result("SRA", 32'hC000_0000);

    // --- Test 6: SLTU (Set Less Than Unsigned) ---
    // 5 < 10 is true (1)
    iDataA = 32'd5;
    iDataB = 32'd10;
    iAluOp = SLTU;
    check_result("SLTU_True", 32'd1);

    // 10 < 5 is false (0)
    iDataA = 32'd10;
    iDataB = 32'd5;
    iAluOp = SLTU;
    check_result("SLTU_False", 32'd0);

    // --- Test 7: SLT (Set Less Than Signed) ---
    // -1 (FFFFFFFF) < 1 (00000001) is true (1)
    iDataA = 32'hFFFF_FFFF;
    iDataB = 32'h0000_0001;
    iAluOp = SLT;
    check_result("SLT_Neg", 32'd1);

    // --- Test 8: Zero Flag Check ---
    iDataA = 32'd5;
    iDataB = 32'd5;
    iAluOp = SUB; // 5 - 5
    #10;
    if (oZero)
      $display("[PASS] Zero Flag: 5 - 5 correctly set oZero");
    else
      $display("[FAIL] Zero Flag: 5 - 5 did not set oZero");

    // --- Test 9: AND ---
    // 1100 & 1010 = 1000 (0xC & 0xA = 0x8)
    iDataA = 32'hC;
    iDataB = 32'hA;
    iAluOp = AND;
    check_result("AND", 32'h8);

    // --- Test 10: OR ---
    // 1100 | 1010 = 1110 (0xC | 0xA = 0xE)
    iDataA = 32'hC;
    iDataB = 32'hA;
    iAluOp = OR;
    check_result("OR", 32'hE);

    // --- Test 11: XOR ---
    // 1100 ^ 1010 = 0110 (0xC ^ 0xA = 0x6)
    iDataA = 32'hC;
    iDataB = 32'hA;
    iAluOp = XOR;
    check_result("XOR", 32'h6);

    $display("--- New ALU Tests Completed ---");
    $finish;
  end
endmodule
