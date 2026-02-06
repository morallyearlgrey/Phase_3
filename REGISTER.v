// Register module definition
module REGISTER (
    input iClk,              // Clock input
    input iRstN,             // Active low reset input
    input iWriteEn,          // Write enable input
    input iReadEnS1,         // Read enable input for source register 1
    input iReadEnS2,         // Read enable input for source register 2
    input [4:0] iRdAddr,     // 5 bit register address input
    input [4:0] iRs1Addr,    // 5 bit source register 1 address input
    input [4:0] iRs2Addr,    // 5 bit source register 2 address input
    input [31:0] iWriteData, // 32 bit data input to store in register
    output [31:0] oRs1Data,  // 32 bit source register 1 data output
    output [31:0] oRs2Data   // 32 bit source register 2 data output
);

    always @(posedge iClk or negedge iRstN) begin
        if (!iRstN) begin
            // Reset logic: Initialize registers to zero
        end else begin
            // Read / Write logic
        end
    end
    
endmodule