/**
 * Verilog code for the full 16-bit ALU.
 * This module instantiates the 1-bit slice 16 times and
 * wires the ripple-carry chain.
 *
 * It correctly implements the S[0] connection to the first Cin
 * for 2's complement subtraction.
 */
module ALU_16bit_top (
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire        S0,
    input  wire        S1,
    output wire [15:0] Result,
    output wire        Cout
);

    // Internal wire for the ripple-carry chain.
    // We need 17 bits:
    // carry_chain[0] is the input to the first slice.
    // carry_chain[1] is the output of the first, input to the second, etc.
    // carry_chain[16] is the final carry-out from the last slice.
    wire [16:0] carry_chain;

    // This is the key to the unified adder/subtractor:
    // The carry-in to the entire ALU (bit 0) is set to S0.
    // If S0=0 (ADD), Cin = 0.
    // If S0=1 (SUB), Cin = 1. (This is the "+ 1" for 2's complement)
    assign carry_chain[0] = S0;

    // This 'generate' block creates 16 instances of our 1-bit slice.
    // It's like a for-loop for hardware.
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin: alu_slice_gen
            
            // Instantiate one 1-bit ALU slice
            ALU_1bit_slice slice_inst (
                .A_i    (A[i]),          // Input A for this bit
                .B_i    (B[i]),          // Input B for this bit
                .Cin    (carry_chain[i]), // Carry-In from previous slice
                .S0     (S0),            // Selector bit 0 (global)
                .S1     (S1),            // Selector bit 1 (global)
                .Result (Result[i]),      // Result output for this bit
                .Cout   (carry_chain[i+1]) // Carry-Out to next slice
            );
            
        end
    endgenerate

    // Assign the final carry-out (from the 16th slice) to the top-level output
    assign Cout = carry_chain[16];

endmodule


/**
 * Verilog code for a 1-bit ALU slice.
 * This module directly corresponds to the hardware design using
 * discrete logic gates and a 4-to-1 MUX.
 *
 * Inputs:
 * A_i    : 1-bit input from Operand A
 * B_i    : 1-bit input from Operand B
 * Cin    : 1-bit Carry-In
 * S0     : Selector bit 0 (LSB)
 * S1     : Selector bit 1 (MSB)
 *
 * Outputs:
 * Result : 1-bit final output
 * Cout   : 1-bit Carry-Out
 */
module ALU_1bit_slice (
    input  wire A_i,
    input  wire B_i,
    input  wire Cin,
    input  wire S0,
    input  wire S1,
    output reg  Result, // Needs to be 'reg' for assignment in 'always' block
    output wire Cout
);

    // --- Internal Wires ---
    wire mux_in_0; // AND result
    wire mux_in_1; // OR result
    wire mux_in_2; // ADD/SUB result
    wire mux_in_3; // ADD/SUB result (wired to same net)

    wire b_modified;
    wire sum_out;

    // --- Logic Unit ---
    // MUX Input I_0: A AND B
    assign mux_in_0 = A_i & B_i;

    // MUX Input I_1: A OR B
    assign mux_in_1 = A_i | B_i;

    // --- Arithmetic Unit ---
    // 1. Controlled Inverter for B-input
    //    (B_i XOR 0) = B_i      (for ADD, S0=0)
    //    (B_i XOR 1) = NOT B_i  (for SUB, S0=1)
    assign b_modified = B_i ^ S0;

    // 2. 1-Bit Full Adder
    //    The adder's output is the result for both ADD and SUB.
    //    Note: Cin is the carry from the previous slice. For bit 0, this will be S0.
    assign sum_out = (A_i ^ b_modified) ^ Cin;
    assign Cout = (A_i & b_modified) | (Cin & (A_i ^ b_modified)); // (This is independent of the MUX)

    // Assign the same sum output to both MUX inputs I_2 and I_3
    assign mux_in_2 = sum_out;
    assign mux_in_3 = sum_out;


    // --- Final 4-to-1 MUX (like 74HC153) ---
    // This always block with a case statement explicitly models a 4-to-1 MUX,
    // which is a clearer structural representation of the 74HC153 hardware.
    always @(*) begin
        case ({S1, S0})
            2'b00:   Result = mux_in_0; // AND
            2'b01:   Result = mux_in_1; // OR
            2'b10:   Result = mux_in_2; // ADD (which is sum_out)
            2'b11:   Result = mux_in_3; // SUB (which is sum_out, same as ADD)
            default: Result = 1'bx;     // Default to unknown to catch errors
        endcase
    end

endmodule
