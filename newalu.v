// ALU module definition
module ALU (
    input [31:0] iDataA, // First 32 bit input operand
    input [31:0] iDataB, // Second 32 bit input operand
    input [3:0] iAluOp,  // 4 bit ALU operation code
    output [31:0] oData, // Output 32 bit result
    output oZero
);
    // ALU operation
    localparam ADD = 4'b0000;
    localparam SUB = 4'b1000;
    localparam SLL = 4'b0001;
    localparam SRL = 4'b1001;
    localparam SRA = 4'b1101;
    localparam SLT = 4'b0010;
    localparam SLTU = 4'b0011;
    localparam XOR = 4'b0100;
    localparam OR = 4'b0110;
    localparam AND = 4'b0111;
    localparam BEQ = 4'b1000;
    localparam BNE = 4'b1100;
    localparam BLT = 4'b1010;
    localparam BGE = 4'b1110;
    
    // Illegal operators
    // * , / , + , - , << , >> , <<< , >>>

    // function multiplexer
    // Use to select the operation based on iFunct3 and iFunct7

    // Combinational logic for ALU operations

endmodule