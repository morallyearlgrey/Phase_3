/* verilator lint_off DECLFILENAME */
// /*
//     Module for the Set Less than Unisigned instruction
//     intakes input A and B, along with the result from the comparator function iSet
//     Outputs oData, either 1 or 0
//         1 if A < B, 0 otherwise
// */

module setLessThan (
    input [31:0] iDataA,
    input [31:0] iDataB,
    output [31:0] oData
  );

  // Find twos complement of B -----
  wire [31:0] invertB;
  wire [31:0] dataBtwo; // twos complement of A
  wire [31:0] diff;
  /* verilator lint_off UNUSED */
  wire oCoutB; // unused
  wire oZeroB; // unused
  /* verilator lint_on UNUSED */
  assign invertB = ~iDataB;

  // Check A - B
  LCA sub (
        .iDataA(iDataA),
        .iDataB(invertB),
        .iCin(1'b1),
        .oData(diff),
        .oCout(oCout),
        .oZero(oZero)
    );

  assign oData = {31'b0, diff[31]}; // if last bit is 1, then overflow -> negative, so A is less than
endmodule
/* verilator lint_on DECLFILENAME */
