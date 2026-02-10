/*
    This file is for my own testing to use the format of the final ALU,
    but to see if my code will be able to integrate into here smoothly
*/
// ALU module definition
module ALU (
    input [31:0] iDataA, // First 32 bit input operand
    input [31:0] iDataB, // Second 32 bit input operand
    input [2:0] iFunct3, // 3 bit function selection
    input [6:0] iFunct7, // 7 bit function selection
    output reg [31:0] oData, // Output 32 bit result
    output reg oZero
);
    // Illegal operators
    // * , / , + , - , << , >> , <<< , >>>
    // so only logic gates and no shifting

    /*
        1. imm or reg? decoder (based on op code)
        2. implement LCA (look ahead carry adder) -> Dawn shall do this
            - This handles Add + Sub (need two's compliment)
        3. bit shifting (shift left and shift right) -> Eren....barrel shifting (w/o clock)
        4. Logical (does not preserve sign) + arithmetic (preseves sign)
            OR (Eren), AND (Dawn), NOT, XOR, Compariter
        5. Multiplexer


        Operations that ALU needs to perform
        Arithmetic Operations:
            1-	Addition.
            2-	Subtraction.
        Logic Operations:
            1-	OR Operation
            2-	AND Operation
            3-	XOR Operation
            4-	Left Shift Operation
            5-	Right Shift Operation.
            6-	Complement.
    */

    wire [31:0] shiftedRes; // result after shifting
    wire [31:0] shamt;
    wire overflow; // detects if there is overflow
    assign overflow =| iDataB[31:5]; // checks if higher than 32 bits
    assign shamt = overflow ? 32'd31 : iDataB; // assigns the shamt

    wire is_sra; // detects if doing arithmetic operation
    assign is_sra = (iFunct3 == 3'b101) && (iFunct7[5] == 1'b1);

    // implements barrel shifter
    // shifts data A by data B
    barrelshifter32 shifting (
        .i(iDataA),
        .s(shamt),
        .func3(iFunct3),
        .is_sra(is_sra),
        .o(shiftedRes)
    );

    // --- OUTPUT MUX ---
    always @(*)
    begin
    oData = 32'b0;

    case (iFunct3)
        3'b001:
        oData = shiftedRes;     // Shift value based on func3 and given func7
        3'b101:
        oData = shiftedRes; // SRL, SRA
        default:
        oData = 32'b0;
    endcase

    // Zero flag (Reduction NOR)
    oZero = ~|oData;
    end

endmodule