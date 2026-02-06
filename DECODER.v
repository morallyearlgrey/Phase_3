// DECODER module definition
module DECODER (
    input [31:0] iInstr, // 32 bit instruction input

    output [6:0] oOpcode, // 7 bit opcode output (all types)
    output [4:0] oRd,     // 5 bit destination register output (R, I, U, J)
    output [2:0] oFunct3, // 3 bit function output (R, I, S, B)
    output [4:0] oRs1,    // 5 bit source register (R, I, S, B)
    output [4:0] oRs2,    // 5 bit source register (R, S, B)
    output [6:0] oFunct7, // 7 bit function output (R)
    output [31:0] oImm    // 32 bit immediate output (I, S, B, U, J)
);
    // oImm:
    //  sign extend
    //  use opcode to determine the immediate bitfields

endmodule