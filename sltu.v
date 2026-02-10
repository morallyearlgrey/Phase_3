/*
    Comparator module compares input and output
    If A > B -> oData[0] = 1
    If A = B -> oData[1] = 1
    If A < B -> oData[2] = 1
*/
module Comparator (
    input [31:0] iDataA,
    input [31:0] iDataB,
    output [2:0] oData
    );
    assign oData[0] = (iDataA > iDataB) ? 1'b1 : 1'b0;
    assign oData[1] = (iDataA = iDataB) ? 1'b1 : 1'b0;
    assign oData[2] = (iDataA < iDataB) ? 1'b1 : 1'b0;
endmodule

/*
    Module for the Set Less than Unisigned instruction
    intakes input A and B
    Uses the comparator to find relationship between A and B
    Outputs oData, either 1 or 0
        1 if A < B, 0 otherwise
*/
module setLessThanUnsigned (
    input [31:0] iDataA,
    input [31:0] iDataB,
    output [31:0] oData
    );
    wire [2:0] iSet; // wire for A and B relationship

    Comparator comp(
        .iDataA(iDataA),
        .iDataB(iDataB),
        .oData(iSet)
    );
    assign oData = (iSet[2] == 1) ? 32'b1 : 32'b0;
endmodule
