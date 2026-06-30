`timescale 1ns / 1ps

module Main_Memory(
    input clk,
    input [3:0] address, // Memory address supplied by the CPU
    input mem_write, // Enables to STORE data
    input [3:0] data_in, // Data from Register File
    output [11:0] data_out // Contents of the selected memory location- can be instruction or data
    );
    
    // Unified memory- stores both instructions and data
    reg [11:0] memory [0:15];
    
    initial begin
        // Sample program
        // Program instructions
        memory[0] = 12'b1100_00_00_1011; // LOAD R0,11
        memory[1] = 12'b1100_01_00_1100; // LOAD R1,12
        memory[2] = 12'b0101_00_01_0000; // SUB R0,R1
        memory[3] = 12'b1011_00_00_0000; // INC R0
        memory[4] = 12'b1101_00_00_1110; // STORE R0,14
        memory[5] = 12'b1110_00_00_0111; // JUMP 7
        memory[6] = 12'b0100_00_01_0000; // ADD R0,R1 (skipped)
        memory[7] = 12'b1111_00_00_0000; // HALT
        
        // Unused locations
        memory[8]  = 12'b0;
        memory[9]  = 12'b0;
        memory[10] = 12'b0;
        
        // Data
        memory[11] = 12'b0000_0000_0111; // 7
        memory[12] = 12'b0000_0000_0011; // 3
        memory[13] = 12'b0000_0000_0000;
        memory[14] = 12'b0000_0000_0000; // Result location
        memory[15] = 12'b0000_0000_0000;
    end
    
    // Combinational read
    assign data_out = memory[address];
        
    // Clocked write operation   
    always @(posedge clk) begin
        if (mem_write)
            memory[address] <= {8'b00000000, data_in}; // Extend 4-bit register data to a 12-bit memory word
    end    
endmodule
