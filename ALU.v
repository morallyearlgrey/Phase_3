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



    // function multiplexer
    // Use to select the operation based on iFunct3 and iFunct7

    // Combinational logic for ALU operations

endmodule