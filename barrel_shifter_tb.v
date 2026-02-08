`timescale 1 ns / 100 ps
`define TESTVECS 4

module tb;
    reg [31:0] data_in; 
    reg [4:0]  shamt; 
    reg [1:0]  op;
    wire [31:0] result;
    
    wire is_left = (op == 2'b00); // 00 = SLL
    wire is_sra  = (op == 2'b11); // 11 = SRA (Arithmetic)

    // Shifter
    barrelshifter32 uut (
        .i(data_in), 
        .s(shamt), 
        .is_left(is_left), 
        .is_sra(is_sra), 
        .o(result)
    );

    initial begin 
        $dumpfile("sim.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        

        $display("----------------------------------------------------------------");
        $display("Time | OP | Data In  | Amt | Result   | Mode");
        $display("----------------------------------------------------------------");

        // SLL (Shift Left Logical) - op 00
        data_in = 32'h0000_0001; shamt = 5'd4; op = 2'b00;
        #10;
        $display("%4t | %b | %h | %d  | %h | SLL (Expect 00000010)", $time, op, data_in, shamt, result);

        // SRL (Shift Right Logical) - op 01
        data_in = 32'hF000_0000; shamt = 5'd4; op = 2'b01;
        #10;
        $display("%4t | %b | %h | %d  | %h | SRL (Expect 0F000000)", $time, op, data_in, shamt, result);

        // SRA (Shift Right Arithmetic) - op 11
        data_in = 32'hF000_0000; shamt = 5'd4; op = 2'b11;
        #10;
        $display("%4t | %b | %h | %d  | %h | SRA (Expect FF000000)", $time, op, data_in, shamt, result);

        // Large Shift
        data_in = 32'hFFFF_FFFF; shamt = 5'd31; op = 2'b01;
        #10;
        $display("%4t | %b | %h | %d | %h | MAX (Expect 00000001)", $time, op, data_in, shamt, result);

        $display("Test Done");
        $finish;
    end
endmodule