`timescale 1ns/1ps

module REGISTER_tb;
    // Declare testbench signals
    reg tb_iClk;
    reg tb_iRstN;
    reg tb_iWriteEn;
    reg tb_iReadEnS1;
    reg tb_iReadEnS2;
    reg [4:0] tb_iRdAddr;
    reg [4:0] tb_iRs1Addr;
    reg [4:0] tb_iRs2Addr;
    reg [31:0] tb_iWriteData;
    wire [31:0] tb_oRs1Data;
    wire [31:0] tb_oRs2Data;

    // Instantiate the module under test
    REGISTER uut (
        .iClk(tb_iClk),
        .iRstN(tb_iRstN),
        .iWriteEn(tb_iWriteEn),
        .iReadEnS1(tb_iReadEnS1),
        .iReadEnS2(tb_iReadEnS2),
        .iRdAddr(tb_iRdAddr),
        .iRs1Addr(tb_iRs1Addr),
        .iRs2Addr(tb_iRs2Addr),
        .iWriteData(tb_iWriteData),
        .oRs1Data(tb_oRs1Data),
        .oRs2Data(tb_oRs2Data)
    );

    // Clock generation (50MHz = 20ns period)
    always #10 tb_iClk = ~tb_iClk;

    // Test sequence
    initial begin
        // Initialize signals
        tb_iClk = 0;
        tb_iRstN = 0;
        tb_iWriteEn = 0;
        tb_iReadEnS1 = 0;
        tb_iReadEnS2 = 0;
        tb_iRdAddr = 5'b0;
        tb_iRs1Addr = 5'b0;
        tb_iRs2Addr = 5'b0;
        tb_iWriteData = 32'b0;

        // Test 1: Reset test
        #20;
        tb_iRstN = 1;
        #20;
        
        // Test 2: Write to register x1
        tb_iWriteEn = 1;
        tb_iRdAddr = 5'd1;
        tb_iWriteData = 32'hDEADBEEF;
        #20;
        
        // Test 3: Write to register x5
        tb_iRdAddr = 5'd5;
        tb_iWriteData = 32'hCAFEBABE;
        #20;
        
        // Test 4: Try writing to x0 (should not work)
        tb_iRdAddr = 5'd0;
        tb_iWriteData = 32'h12345678;
        #20;
        
        tb_iWriteEn = 0;
        
        // Test 5: Read from x1 and x5
        tb_iReadEnS1 = 1;
        tb_iReadEnS2 = 1;
        tb_iRs1Addr = 5'd1;
        tb_iRs2Addr = 5'd5;
        #20;
        
        // Test 6: Read from x0 (should always be 0)
        tb_iRs1Addr = 5'd0;
        tb_iRs2Addr = 5'd0;
        #20;
        
        // Test 7: Simultaneous write and read
        tb_iWriteEn = 1;
        tb_iRdAddr = 5'd10;
        tb_iWriteData = 32'hABCD1234;
        tb_iRs1Addr = 5'd10;
        #20;
        
        // Test 8: Reset while holding data
        tb_iRstN = 0;
        #20;
        tb_iRstN = 1;
        tb_iReadEnS1 = 1;
        tb_iRs1Addr = 5'd1;
        #20;
        
        $display("All tests completed");
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t | Rst=%b | WE=%b | WAddr=%d | WData=%h | RS1=%d | RData1=%h | RS2=%d | RData2=%h",
                 $time, tb_iRstN, tb_iWriteEn, tb_iRdAddr, tb_iWriteData, 
                 tb_iRs1Addr, tb_oRs1Data, tb_iRs2Addr, tb_oRs2Data);
    end

    // Optional: Dump waveforms for viewing
    initial begin
        $dumpfile("register_tb.vcd");
        $dumpvars(0, REGISTER_tb);
    end

endmodule