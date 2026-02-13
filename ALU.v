// ALU module definition
`include "AND.v"
`include "barrel_shifter.v"
`include "comparator.v"
`include "LCA.v"
`include "OR.v"
`include "slt.v"
`include "sltu.v"
`include "XOR.v"


// ALU module definition
module ALU (
    input [31:0] iDataA, // First 32 bit input operand
    input [31:0] iDataB, // Second 32 bit input operand
    input [3:0] iAluOp,  // 4 bit ALU operation code
    output reg [31:0] oData, // Output 32 bit result
    output reg oZero
  );

  // ALU operation codes (from newalu.v)
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

  // Branch ops (mapped to subtraction generally for flags)
  localparam BEQ  = 4'b1000;
  localparam BNE  = 4'b1100;
  localparam BLT  = 4'b1010;
  localparam BGE  = 4'b1110;

  // Illegal operators
  // * , / , + , - , << , >> , <<< , >>>
  // so only logic gates and no shifting

  //
  //     1. imm or reg? decoder (based on op code)
  //     2. implement LCA (look ahead carry adder) > Dawn shall do this
  //          This handles Add and Sub (need two's compliment)
  //     3. bit shifting (shift left and shift right) > Eren....barrel shifting (wo clock)
  //     4. Logical (does not preserve sign) and arithmetic (preseves sign)
  //         OR (Eren), AND (Dawn), NOT, XOR, Compariter
  //     5. Multiplexer


  //     Operations that ALU needs to perform
  //     Arithmetic Operations:
  //         1	Addition.
  //         2	Subtraction.
  //     Logic Operations:
  //         1	OR Operation
  //         2	AND Operation
  //         3	XOR Operation
  //         4	Left Shift Operation
  //         5	Right Shift Operation.
  //         6	Complement.
  //


  // function multiplexer
  // Use to select the operation based on iAluOp

  // Combinational logic for ALU operations


  // --- ADDER MODULE (LCA) ---
  // Prepare B input for subtraction (2's complement inversion)
  // Note: The +1 is handled by iCin
  // SUB, BEQ, BNE, BLT, BGE involve subtraction logic
  wire is_sub = (iAluOp == SUB) || (iAluOp == BNE) || (iAluOp == BLT) || (iAluOp == BGE);
  wire [31:0] adder_b = is_sub ? ~iDataB : iDataB;  // If subtracting, perform bitwise inversion of iDataB to prepare for 2's complement addition
  wire [31:0] wSum;
  /* verilator lint_off UNUSED */
  wire wCout; // Unused for ADD/SUB result directly, but needed for Comparator
  wire wAdderZero; // Unused
  /* verilator lint_on UNUSED */

  LCA u_adder (
        .iDataA(iDataA),
        .iDataB(adder_b),
        .iCin(is_sub),
        .oData(wSum),
        .oCout(wCout),
        .oZero(wAdderZero)
      );
  // End Adder module stuff

  // -- BARREL SHIFTER MODULE ---
  wire [31:0] shiftedRes; // result after shifting
  wire [31:0] shamt;

  wire overflow; // detects if there is overflow
  assign overflow =| iDataB[31:5]; // checks if higher than 32 bits
  assign shamt = overflow ? 32'd31 : iDataB; // assigns the shamt

  wire is_sra; // detects if doing arithmetic operation
  assign is_sra = (iAluOp == SRA);

  // Derive funct3 for barrel shifter (SLL=001, SRL=101, SRA=101)
  wire [2:0] derived_funct3 = (iAluOp == SLL) ? 3'b001 : 3'b101;

  // implements barrel shifter
  // shifts data A by data B
  barrelshifter32 shifting (
                    .i(iDataA),
                    .s(shamt),
                    .func3(derived_funct3),
                    .is_sra(is_sra),
                    .o(shiftedRes)
                  );

  // --- SLT MODULE ---
  wire [31:0] slt_res;
  slt SLTmod(
                .iDataA(iDataA),
                .iDataB(iDataB),
                .oData(slt_res)
              );

  // --- SLTU MODULE ---
  wire [31:0] sltu_res;
  setLessThanUnsigned SLTUmod(
                        .iDataA(iDataA),
                        .iDataB(iDataB),
                        .oData(sltu_res)
                      );

  // --- AND MODULE ---
  wire [31:0] wAnd;
  AND u_and (
        .iDataA(iDataA),
        .iDataB(iDataB),
        .oData(wAnd)
      );

  // --- OR MODULE ---
  wire [31:0] wOr;
  OR u_or (
       .iDataA(iDataA),
       .iDataB(iDataB),
       .oData(wOr)
     );

  // --- XOR MODULE ---
  wire [31:0] wXor;
  XOR u_xor (
        .iDataA(iDataA),
        .iDataB(iDataB),
        .oData(wXor)
      );

  // --- OUTPUT MUX ---
  always @(*)
  begin
    oData = 32'b0;
    oZero = 1'b0; // Default

    case (iAluOp)
      ADD, SUB:
      begin
        oData = wSum;           // ADD, SUB
        oZero = ~|oData;
      end
      SLL, SRL, SRA:
      begin
        oData = shiftedRes;     // Shifts
        oZero = ~|oData;
      end
      SLT:
      begin
        oData = slt_res;        // SLT
        oZero = ~|oData;
      end
      SLTU:
      begin
        oData = sltu_res;       // SLTU
        oZero = ~|oData;
      end
      XOR:
      begin
        oData = wXor;           // XOR
        oZero = ~|oData;
      end
      OR:
      begin
        oData = wOr;            // OR
        oZero = ~|oData;
      end
      AND:
      begin
        oData = wAnd;           // AND
        oZero = ~|oData;
      end

      // Branch Ops
      // BEQ:
      // begin
      //   oData = wSum;    // Subtraction result
      //   oZero = ~|oData; // 1 if Equal (result is 0)
      // end
      BNE:
      begin
        oData = wSum;    // Subtraction result
        oZero = |oData;  // 1 if Not Equal (result is not 0)
      end
      BLT:
      begin
        oData = wSum;       // Subtraction result
        oZero = slt_res[0]; // 1 if Less Than (A < B)
      end
      BGE:
      begin
        oData = wSum;        // Subtraction result
        oZero = ~slt_res[0]; // 1 if Greater or Equal (A >= B)
      end

      default:
      begin
        oData = 32'b0;
        oZero = ~|oData;
      end
    endcase
  end

endmodule
