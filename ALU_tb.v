`timescale 1ns / 1ps

module ALU_tb();
    reg [31:0] iDataA;
    reg [31:0] iDataB;
    reg [2:0]  iFunct3;
    reg [6:0]  iFunct7;

    wire [31:0] oData;
    wire        oZero;

    ALU uut (
        .iDataA(iDataA), 
        .iDataB(iDataB), 
        .iFunct3(iFunct3), 
        .iFunct7(iFunct7), 
        .oData(oData), 
        .oZero(oZero)
    );

    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, ALU_tb);

        $display("Starting ALU Shifter Tests...");
        $display("---------------------------------------");

        // Shift 0x0000_0007 left by 2 bits -> Result should be 0x0000_001C
        iDataA  = 32'h0000_0007; 
        iDataB  = 32'd2; 
        iFunct3 = 3'b001; 
        iFunct7 = 7'b0000000;
        #10; 
        $display("SLL | A: %h, Shamt: %d | Result: %h | Zero: %b", iDataA, iDataB, oData, oZero);

        // Shift 0x8000_0000 right by 1 bit -> Result should be 0x4000_0000
        iDataA  = 32'h8000_0000; 
        iDataB  = 32'd1; 
        iFunct3 = 3'b101; 
        iFunct7 = 7'b0000000;
        #10;
        $display("SRL | A: %h, Shamt: %d | Result: %h | Zero: %b", iDataA, iDataB, oData, oZero);

        // Shift 0x8000_0000 right by 1 bit -> Result should be 0xC000_0000 (sign bit preserved)
        iDataA  = 32'h8000_0000; 
        iDataB  = 32'd1; 
        iFunct3 = 3'b101; 
        iFunct7 = 7'b0100000; // Bit 5 of Funct7 indicates SRA
        #10;
        $display("SRA | A: %h, Shamt: %d | Result: %h | Zero: %b", iDataA, iDataB, oData, oZero);

        // Shift 0x0000_FFFF left by 35 bits. 
        iDataA  = 32'h0000_FFFF; 
        iDataB  = 32'd35; 
        iFunct3 = 3'b001; 
        iFunct7 = 7'b0000000;
        #10;
        $display("OVR | A: %h, Shamt: %d | Result: %h | Zero: %b", iDataA, iDataB, oData, oZero);

        $display("---------------------------------------");
        $display("Tests Completed.");
        $finish;
    end
endmodule