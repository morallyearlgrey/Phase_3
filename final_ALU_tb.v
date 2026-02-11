/*
    Final ALU test bench used
*/

`timescale 1ns / 1ps

module ALU_tb();
  // Inputs
  reg [31:0] iDataA;
  reg [31:0] iDataB;
  reg [2:0]  iFunct3;
  reg [6:0]  iFunct7;

  // Outputs
  wire [31:0] oData;
  wire        oZero;

  // Instantiate the Unit Under Test (UUT)
  ALU uut (
        .iDataA(iDataA),
        .iDataB(iDataB),
        .iFunct3(iFunct3),
        .iFunct7(iFunct7),
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
        $display("[PASS] %s | A:%h B:%h | Result:%h", op_name, iDataA, iDataB, oData);
      else
        $display("[FAIL] %s | A:%h B:%h | Result:%h (Exp:%h)", op_name, iDataA, iDataB, oData, expected);
    end
  endtask

  initial
  begin
    $dumpfile("alu_sim.vcd");
    $dumpvars(0, ALU_tb);

    $display("--- Starting Comprehensive ALU Tests ---");

    // --- Test 1: Addition (Funct3: 000, Funct7: 0000000) ---
    iDataA = 32'd10;
    iDataB = 32'd5;
    iFunct3 = 3'b000;
    iFunct7 = 7'b0000000;
    check_result("ADD", 32'd15);

    // --- Test 2: Subtraction (Funct3: 000, Funct7: 0100000) ---
    // Note: Ensure your ALU defines 'is_sub' as iFunct7[5]
    iDataA = 32'd20;
    iDataB = 32'd7;
    iFunct3 = 3'b000;
    iFunct7 = 7'b0100000;
    check_result("SUB", 32'd13);

    // --- Test 3: SLL (Shift Left Logical) ---
    iDataA = 32'h0000_0001;
    iDataB = 32'd4;
    iFunct3 = 3'b001;
    iFunct7 = 7'b0000000;
    check_result("SLL", 32'h0000_0010);

    // --- Test 4: SRL (Shift Right Logical) ---
    iDataA = 32'h8000_0000;
    iDataB = 32'd1;
    iFunct3 = 3'b101;
    iFunct7 = 7'b0000000;
    check_result("SRL", 32'h4000_0000);

    // --- Test 5: SRA (Shift Right Arithmetic) ---
    iDataA = 32'h8000_0000;
    iDataB = 32'd1;
    iFunct3 = 3'b101;
    iFunct7 = 7'b0100000;
    check_result("SRA", 32'hC000_0000);

    // --- Test 6: SLTU (Set Less Than Unsigned) ---
    // 5 < 10 is true (1)
    iDataA = 32'd5;
    iDataB = 32'd10;
    iFunct3 = 3'b011;
    iFunct7 = 7'b0000000;
    check_result("SLTU_True", 32'd1);

    // 10 < 5 is false (0)
    iDataA = 32'd10;
    iDataB = 32'd5;
    iFunct3 = 3'b011;
    iFunct7 = 7'b0000000;
    check_result("SLTU_False", 32'd0);

    // --- Test 7: SLT (Set Less Than Signed) ---
    // -1 (FFFFFFFF) < 1 (00000001) is true (1)
    iDataA = 32'hFFFF_FFFF;
    iDataB = 32'h0000_0001;
    iFunct3 = 3'b010;
    iFunct7 = 7'b0000000;
    check_result("SLT_Neg", 32'd1);

    // --- Test 8: Zero Flag Check ---
    iDataA = 32'd5;
    iDataB = 32'd5;
    iFunct3 = 3'b000;
    iFunct7 = 7'b0100000; // 5 - 5
    #10;
    if (oZero)
      $display("[PASS] Zero Flag: 5 - 5 correctly set oZero");
    else
      $display("[FAIL] Zero Flag: 5 - 5 did not set oZero");

    // --- Test 9: AND (Funct3: 111, Funct7: 0000000) ---
    // 1100 & 1010 = 1000 (0xC & 0xA = 0x8)
    iDataA = 32'hC;
    iDataB = 32'hA;
    iFunct3 = 3'b111;
    iFunct7 = 7'b0000000;
    check_result("AND", 32'h8);

    // --- Test 10: OR (Funct3: 110, Funct7: 0000000) ---
    // 1100 | 1010 = 1110 (0xC | 0xA = 0xE)
    iDataA = 32'hC;
    iDataB = 32'hA;
    iFunct3 = 3'b110;
    iFunct7 = 7'b0000000;
    check_result("OR", 32'hE);

    // --- Test 11: XOR (Funct3: 100, Funct7: 0000000) ---
    // 1100 ^ 1010 = 0110 (0xC ^ 0xA = 0x6)
    iDataA = 32'hC;
    iDataB = 32'hA;
    iFunct3 = 3'b100;
    iFunct7 = 7'b0000000;
    check_result("XOR", 32'h6);

    $display("--- ALU Tests Completed ---");
    $finish;
  end
endmodule
