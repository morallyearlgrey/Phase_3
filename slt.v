/*
    Module for the Set Less than Unisigned instruction
    intakes input A and B, along with the result from the comparator function iSet
    Outputs oData, either 1 or 0
        1 if A < B, 0 otherwise
*/


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

// USING DAWN'S 32-bit Lookahead Carry Adder
module LCA (
    input [31:0] iDataA,
    input [31:0] iDataB,
    input iCin,          // Added Cin input for subtraction support (so we can this for both operations)
    output [31:0] oData,
    output oCout,        // Exposed Cout
    output oZero
    );

    wire [31:0] sum;

    // Carry prop wires between 4-bit blocks
    wire c4, c8, c12, c16, c20, c24, c28;

    // Instantiate 8 4-bit LCAs
    LCA4 bit0_3   (iDataA[3:0],   iDataB[3:0],   iCin, sum[3:0],   c4);
    LCA4 bit4_7   (iDataA[7:4],   iDataB[7:4],   c4,   sum[7:4],   c8);
    LCA4 bit8_11  (iDataA[11:8],  iDataB[11:8],  c8,   sum[11:8],  c12);
    LCA4 bit12_15 (iDataA[15:12], iDataB[15:12], c12,  sum[15:12], c16);
    LCA4 bit16_19 (iDataA[19:16], iDataB[19:16], c16,  sum[19:16], c20);
    LCA4 bit20_23 (iDataA[23:20], iDataB[23:20], c20,  sum[23:20], c24);
    LCA4 bit24_27 (iDataA[27:24], iDataB[27:24], c24,  sum[27:24], c28);
    LCA4 bit28_31 (iDataA[31:28], iDataB[31:28], c28,  sum[31:28], oCout);

    assign oData = sum;

    // Zero flag (Reduction NOR)
    assign oZero = ~|sum;

    endmodule

// 4-bit Lookahead Carry Adder
module LCA4 (
        input [3:0] a,
        input [3:0] b,
        input cin,
        output [3:0] s,
        output cout
    );

    wire [3:0] p, g;
    wire [4:0] c;

    // Generate and Propagate
    assign g = a & b;
    assign p = a ^ b;

    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & c[2]);
    assign c[4] = g[3] | (p[3] & c[3]); // This is cout for the block

    assign s = p ^ c[3:0];
    assign cout = c[4];

endmodule

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
        .iDataB(31'b1),
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
    assign invertA = ~iDataB;

    LCA adderB(
        .iDataA(invertA),
        .iDataB(31'b1),
        .iCin(1'b0),
        .oData(dataBtwo),
        .oCout(oCoutB),
        .oZero(oZeroB)
    );

    wire [2:0] iSet; // holds relationship between A and B

    // NOW COMPARE A (twos comp) AND B (twos com)
    Comparator comp(
        .iDataA(dataAtwo),
        .iDataB(dataBtwo),
        .oData(iSet)
    );

    assign oData = (iSet[2] == 1) ? 32'b1 : 32'b0;
endmodule