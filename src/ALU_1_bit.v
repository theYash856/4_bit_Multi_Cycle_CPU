`timescale 1ns / 1ps

module ALU_1_bit(input A, B, input [2:0]opcode, input Cin, output reg Y, output reg carry);

    always @(*) begin
        carry = 0;   // default
        Y=0;
        case(opcode)
            // Logical operators 
            3'b000: Y = A & B; // AND
            3'b001: Y = A | B; // OR
            3'b010: Y = ~A; // NOT A
            3'b011: Y = ~(A & B); // NAND
            3'b100: Y = A ^ B; // XOR
            3'b101: Y = ~(A | B); // NOR
            
            // Arithmetic operators 
            3'b110: {carry, Y} = A + B + Cin; // ADD
            3'b111: {carry, Y} = A + B + Cin; // SUB: B will be complemented in 4-bit ALU separately
            default: Y = 0;
        endcase
      end
endmodule