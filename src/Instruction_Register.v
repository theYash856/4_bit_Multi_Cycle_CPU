`timescale 1ns / 1ps

module Instruction_Register(
    input clk,
    input rst,
    input load, // Load instruction during FETCH
    input [11:0] instruction_in,

    output [11:0] instruction_out
    );
    reg [11:0] IR;

    always @(posedge clk or posedge rst)
    begin
        if(rst)
            IR <= 12'b0;
        else if(load)
            IR <= instruction_in;
    end
    
    assign instruction_out = IR;
endmodule