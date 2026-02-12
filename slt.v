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
  // Find twos complement of each data -----
  wire [31:0] invertA;
  wire [31:0] dataAtwo; // twos complement of A
  wire oCout; // unused
  wire oZero; // unused
  assign invertA = ~iDataA;

  LCA adderA(
        .iDataA(invertA),
        .iDataB(32'b1),
        .iCin(1'b0),
        .oData(dataAtwo),
        .oCout(oCout),
        .oZero(oZero)
      );

  // Find twos complement of each data -----
  wire [31:0] invertB;
  wire [31:0] dataBtwo; // twos complement of A
  wire oCoutB; // unused
  wire oZeroB; // unused
  assign invertB = ~iDataB;

  LCA adderB(
        .iDataA(invertB),
        .iDataB(32'b1),
        .iCin(1'b0),
        .oData(dataBtwo),
        .oCout(oCoutB),
        .oZero(oZeroB)
      );

  wire [2:0] iSet; // holds relationship between A and B

  // NOW COMPARE A (twos comp) AND B (twos com)
  Comparator SLTcomp(
               .iDataA(dataAtwo),
               .iDataB(dataBtwo),
               .oData(iSet)
             );

  assign oData = (iSet[2] == 1) ? 32'b1 : 32'b0;
endmodule
