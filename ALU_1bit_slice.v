 /**
 * Verilog code for a 1-bit ALU slice.
 * This module directly corresponds to the hardware design using
 * discrete logic gates and a 4-to-1 MUX.
 *
 * Inputs:
 * A :1-bit data input from Operand A
 * B :1-bit data input from Operand B
 * Cin : 1-bit Carry-In from the previous slice
 * S1 : Selector bit 1 (Top-level MUX control)
 * S0 : Selector bit 0 (Low-level MUX control and Arithmetic control)
 *
 * Outputs:
 * Result : 1-bit result of the selected operation
 * Cout : 1-bit Carry-Out to the next slice
 *
 * Operation Table (S[1:0]):
 * 00 : A AND B
 * 01 : A OR B
 * 10 : A + B + Cin (Add)
 * 11 : A- B (Subtract, via A + (!B) + 1)
 */
 module ALU_1bit_slice (
 input wire A,
 input wire B,
 input wire Cin,
 input wire S1,
 input wire S0,
 output reg Result, // Changed to 'reg' for use in always block
 output wire Cout
 );
 //--- Internal Wires--
// Wires for the 4 MUX inputs
 wire mux_in_0; // (S[1:0] = 00)
 wire mux_in_1; // (S[1:0] = 01)
 wire mux_in_2; // (S[1:0] = 10)
 wire mux_in_3; // (S[1:0] = 11)
 // Wires for the unified Arithmetic unit
 wire b_modified;
 wire sum_out;
 // Wires for full-adder internal logic (for clarity)
 wire fa_xor1;
 wire fa_and1;
 wire fa_and2;
 //--- 1. Logic Unit (for MUX inputs I_0 and I_1)--
// MUX Input 0: A AND B
 assign mux_in_0 = A & B;
 // MUX Input 1: A OR B
 assign mux_in_1 = A | B;
 //--- 2. Unified Arithmetic Unit (for MUX inputs I_2 and I_3)--
// This is the clever part: S0 controls the B operand.
 // if S0=0 (Add), b_modified = B ^ 0 = B
 // if S0=1 (Sub), b_modified = B ^ 1 = NOT B
 assign b_modified = B ^ S0;
 // Full Adder Logic (built from gates)
 assign fa_xor1 = A ^ b_modified;
 assign sum_out = fa_xor1 ^ Cin;
 assign fa_and1 = fa_xor1 & Cin;
 assign fa_and2 = A & b_modified;
 assign Cout
 // Sum output of the adder
 = fa_and1 | fa_and2; // Cout is the final Carry-Out
 // (This is independent of the MUX)
 // The adder's sum output is fed to *both* I_2 and I_3 of the MUX
 assign mux_in_2 = sum_out;
 assign mux_in_3 = sum_out;
 //--- 3. Final 4-to-1 MUX--
// This always block with a case statement explicitly models a 4-to-1 MUX,
 // which is a clearer structural representation of the 74HC153 hardware.
 // Combinational logic, so we use @(*)
 always @(*) begin
 case ({S1, S0})
 2'b00:
 Result = mux_in_0; // AND
 2'b01:
 2'b10:
 2'b11:
 Result = mux_in_1; // OR
 Result = mux_in_2; // ADD
 Result = mux_in_3; // SUB (which is sum_out, same as ADD)
 default: Result = 1'bx;
 // Default to unknown to catch errors
 endcase
 end
 endmodule
