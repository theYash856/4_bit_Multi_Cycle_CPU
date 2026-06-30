`timescale 1ns / 1ps

module Program_Counter(
    input clk,
    input rst,
    input jump,
    input pc_enable, // Enables PC update only during WRITEBACK.
    input [3:0] jump_address, // To store address in case jump happens
    output reg [3:0] pc // Current instruction address
    );
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 4'b0000;
        else if (jump)
            pc <= jump_address;
        else if (pc_enable)
            pc <= pc + 1'b1;
    end
    
endmodule
