/* verilator lint_off DECLFILENAME */
// /*
//     Implements barrel shifter
//     Allows for shifting left, right, and shift left arithmetic

//     Input:
//         32 bit input wire i: stores data for value to be shifted
//         5 bit s:             shift amount value, 5 total stages to accomodate 32 bit numbers
//         3 bit func3:         wire to determine is sll or srl
//         7 bit fun7:          wire to determine if srl arithemtic or not

//     Output:
//         32 bit wire o: final resulting value shifted by s
// */

// multiplexer module
module mux2 (input wire i0, i1, j, output wire o);
  wire not_j, w1, w2;
  // if j = 0, o = i0
  // if j = 1, o = i1

  not (not_j, j); // invert j
  // compare i0 and i1 to invert j
  and (w1, i0, not_j);
  and (w2, i1, j);

  or  (o, w1, w2); // o becomes whichever is true
endmodule

module shifter_stage #(parameter DIST = 1) (
    input  wire [31:0]  i,
    input  wire         s,       // 1 to shift, 0 to pass through
    /* verilator lint_off UNUSED */
    input  wire [2:0]   func3, // holds value for func3 to determine shifting
    /* verilator lint_on UNUSED */
    input  wire         is_sra,  // holds func7...010 is sra
    output wire [31:0] o
  );
  // wire [31:0] shifted_val; // UNUSED
  wire fill_bit;

  // if shift right arithmetic (sra), then fills with signed bit i[31]
  // if not, then 0
  and (fill_bit, is_sra, i[31]);

  genvar k;
  generate
    for (k = 0; k < 32; k = k + 1)
    begin : bit_logic
      wire left_val, right_val, target_val;

      // if left of current bit, then we need to shift left
      if (k < DIST)
        assign left_val = 1'b0; // fills 0 on right
      else
        assign left_val = i[k - DIST]; // if not shift, then put into current place

      // Right shifting
      if (k >= 32 - DIST)
        assign right_val = fill_bit; // fills 0 or signed bit (if sra)
      else
        assign right_val = i[k + DIST];

      // determine l or r
      mux2 dir_mux (left_val, right_val, func3[2], target_val); // passing fun3[2] to determine if r or l

      // Determine if shift or pass
      mux2 final_mux (i[k], target_val, s, o[k]);
    end
  endgenerate
endmodule

// Main barrel shifter module
module barrelshifter32(
    input  wire [31:0] i,
    /* verilator lint_off UNUSED */
    input  wire [31:0]  s, // enable bits for each stage
    /* verilator lint_on UNUSED */
    input  wire [2:0]   func3, // determines if shifting left
    input  wire         is_sra, // determines if shift right arithmetic
    output wire [31:0] o
  );
  wire [31:0] t16, t8, t4, t2;

  shifter_stage #(.DIST(16)) s16 (i,   s[4], func3, is_sra, t16);
  shifter_stage #(.DIST(8))  s8  (t16, s[3], func3, is_sra, t8);
  shifter_stage #(.DIST(4))  s4  (t8,  s[2], func3, is_sra, t4);
  shifter_stage #(.DIST(2))  s2  (t4,  s[1], func3, is_sra, t2);
  shifter_stage #(.DIST(1))  s1  (t2,  s[0], func3, is_sra, o);

endmodule
/* verilator lint_on DECLFILENAME */
