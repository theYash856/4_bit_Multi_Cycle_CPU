`timescale 1ns / 1ps

module ALU_4_bit(input [3:0]A_4bit, B_4bit, 
                 input [2:0]opcode_4bit,
                 output [3:0]Y_4bit, // Since we will instantiate it is not in always block so reg type not needed.
                 output Cout);
  
    wire [2:0]C_4bit; // Carry propagating in between wires after Cin_4bit
    
    // Step: 1 Decide Cin_4bit value (Initial carry)
    wire Cin_4bit;
    assign Cin_4bit = (opcode_4bit == 3'b111); // It checks if opcode is equal to 111 (SUB); equal then 1 otherwise 0
    
    // Step: 2 Declare B_final as GLOBAL (earlier the inversion was happening at per bit level which confused the ripple carry; mixing control and datapath.)
    wire [3:0]B_final;
    assign B_final = B_4bit ^ {4{Cin_4bit}};
    
    // Step 3: Instantiate  4 1bit ALU    
    ALU_1_bit a1(.A(A_4bit[0]), .B(B_final[0]), .opcode(opcode_4bit), .Cin(Cin_4bit),  .Y(Y_4bit[0]), .carry(C_4bit[0]));
    ALU_1_bit a2(.A(A_4bit[1]), .B(B_final[1]), .opcode(opcode_4bit), .Cin(C_4bit[0]), .Y(Y_4bit[1]), .carry(C_4bit[1]));
    ALU_1_bit a3(.A(A_4bit[2]), .B(B_final[2]), .opcode(opcode_4bit), .Cin(C_4bit[1]), .Y(Y_4bit[2]), .carry(C_4bit[2]));
    ALU_1_bit a4(.A(A_4bit[3]), .B(B_final[3]), .opcode(opcode_4bit), .Cin(C_4bit[2]), .Y(Y_4bit[3]), .carry(Cout));
     
endmodule
