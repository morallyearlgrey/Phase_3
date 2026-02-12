// /*
//     Module for the Set Less than Unisigned instruction
//     intakes input A and B
//     Uses the comparator to find relationship between A and B
//     Outputs oData, either 1 or 0
//         1 if A < B, 0 otherwise
// */
module setLessThanUnsigned (
    input [31:0] iDataA,
    input [31:0] iDataB,
    output [31:0] oData
    );
    wire [2:0] iSet; // wire for A and B relationship

    Comparator SLTUcomp(
        .iDataA(iDataA),
        .iDataB(iDataB),
        .oData(iSet)
    );
    assign oData = (iSet[2] == 1) ? 32'b1 : 32'b0;
endmodule
