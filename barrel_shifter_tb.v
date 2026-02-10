`timescale 1 ns / 100 ps
`define TESTVECS 4

module tb;
    reg [31:0] data_in;
    reg [4:0]  shamt;
    reg [2:0]  func3;
    reg [6:0]  func7;
    wire [31:0] result;
    
    wire is_left = (func3 == 3'b001);
    wire is_sra = (func7 == 7'b0100000);

    // Shifter
    barrelshifter32 uut (
        .i(data_in),
        .s(shamt),
        .func3(is_left),
        .func7(is_sra),
        .o(result)
    );

    initial begin 
        $dumpfile("sim.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        

        $display("----------------------------------------------------------------");
        $display("Time | Func3 | Func7 | Data In  | Amt | Result   | Mode");
        $display("----------------------------------------------------------------");

        // SLL (Shift Left Logical) - func3 001
        data_in = 32'h0000_0001; shamt = 5'd4; func3 = 3'b001; func7 = 7'b0000000;
        #10;
        $display("%4t | %b | %b | %h | %d  | %h | SLL (Expect 00000010)", $time, func3, func7, data_in, shamt, result);

        // SRL (Shift Right Logical) - fun3 101
        data_in = 32'hF000_0000; shamt = 5'd4; func3 = 3'b101; func7 = 7'b0000000;
        #10;
        $display("%4t | %b | %b | %h | %d  | %h | SRL (Expect 0F000000)", $time, func3, func7, data_in, shamt, result);

        // SRA (Shift Right Arithmetic) - func 3 101....func 7 010 0000
        data_in = 32'hF000_0000; shamt = 5'd4; func3 = 3'b101; func7 = 7'b0100000;
        #10;
        $display("%4t | %b | %b | %h | %d  | %h | SRA (Expect FF000000)", $time, func3, func7, data_in, shamt, result);

        $display("Test Done");
        $finish;
    end
endmodule