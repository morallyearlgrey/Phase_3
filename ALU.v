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

    // function multiplexer
    // Use to select the operation based on iFunct3 and iFunct7

    // Combinational logic for ALU operations

endmodule