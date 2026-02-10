// ALU module definition
module ALU (
    input [31:0] iDataA, // First 32 bit input operand
    input [31:0] iDataB, // Second 32 bit input operand
    input [2:0] iFunct3, // 3 bit function selection
    input [6:0] iFunct7, // 7 bit function selection
    output reg [31:0] oData, // Output 32 bit result
    output reg oZero
);
    // Illegal operators
    // * , / , + , - , << , >> , <<< , >>>
    // so only logic gates and no shifting

    /*
        1. imm or reg? decoder (based on op code)
        2. implement LCA (look ahead carry adder) -> Dawn shall do this
            - This handles Add + Sub (need two's compliment)
        3. bit shifting (shift left and shift right) -> Eren....barrel shifting (w/o clock)
        4. Logical (does not preserve sign) + arithmetic (preseves sign)
            OR (Eren), AND (Dawn), NOT, XOR, Compariter
        5. Multiplexer


        Operations that ALU needs to perform
        Arithmetic Operations:
            1-	Addition.
            2-	Subtraction.
        Logic Operations:
            1-	OR Operation
            2-	AND Operation
            3-	XOR Operation
            4-	Left Shift Operation
            5-	Right Shift Operation.
            6-	Complement.
    */



    // function multiplexer
    // Use to select the operation based on iFunct3 and iFunct7

    // Combinational logic for ALU operations


    // --- ADDER MODULE (LCA) ---
    // Prepare B input for subtraction (2's complement inversion)
    // Note: The +1 is handled by iCin
    wire [31:0] adder_b = is_sub ? ~iDataB : iDataB;  // If subtracting, perform bitwise inversion of iDataB to prepare for 2's complement addition
    wire [31:0] wSum;
    wire wCout; // Unused for ADD/SUB result directly, but needed for Comparator
    wire wAdderZero; // Unused

    LCA u_adder (
            .iDataA(iDataA),
            .iDataB(adder_b),
            .iCin(is_sub),
            .oData(wSum),
            .oCout(wCout),
            .oZero(wAdderZero)
        );
    // End Adder module stuff

    // -- BARREL SHIFTER MODULE ---
    wire [31:0] shiftedRes; // result after shifting
    wire [31:0] shamt;

    wire overflow; // detects if there is overflow
    assign overflow =| iDataB[31:5]; // checks if higher than 32 bits
    assign shamt = overflow ? 32'd31 : iDataB; // assigns the shamt

    wire is_sra; // detects if doing arithmetic operation
    assign is_sra = (iFunct3 == 3'b101) && (iFunct7[5] == 1'b1);

    // implements barrel shifter
    // shifts data A by data B
    barrelshifter32 shifting (
        .i(iDataA),
        .s(shamt),
        .func3(iFunct3),
        .is_sra(is_sra),
        .o(shiftedRes)
    );

    // --- SLT MODULE ---
    wire [31:0] slt_res;
    setLessThan(
        .iDataA(iDataA),
        .iDataB(iDataB),
        .oData(sltu_res)
    );

    // --- SLT MODULE ---
    wire [31:0] sltu_res;
    setLessThanUnsigned(
        .iDataA(iDataA),
        .iDataB(iDataB),
        .oData(sltu_res)
    );

    // --- OUTPUT MUX ---
    always @(*)
    begin
    oData = 32'b0;

    case (iFunct3)
        3'b000:
        oData = wSum;           // ADD, SUB
        3'b001:
        oData = shiftedRes;     // Shift value based on func3 and given func7
        3'b010:
        oData = slt_res; // SLT Holder
        3'b011:
        oData = sltu_res; // SLTU Holder
        3'b100:
        oData = wXor;           // XOR
        3'b101:
        oData = shiftedRes; // SRL, SRA
        3'b110:
        oData = wOr;            // OR
        3'b111:
        oData = wAnd;           // AND
        
        default:
        oData = 32'b0;
    endcase

    // Zero flag (Reduction NOR)
    oZero = ~|oData;
    end

endmodule