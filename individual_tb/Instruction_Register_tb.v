`timescale 1ns / 1ps

module Instruction_Register_tb;

    reg clk_tb, rst_tb, load_tb;
    reg [11:0] instruction_in_tb;
    wire [11:0] instruction_out_tb;

    Instruction_Register uut(.clk(clk_tb), .rst(rst_tb), .load(load_tb), .instruction_in(instruction_in_tb),
                             .instruction_out(instruction_out_tb));
   
    // Generates VCD waveform files for online EDA tools.
    initial begin
        $dumpfile("Instruction_Register.vcd");
        $dumpvars(0, Instruction_Register_tb);
    end 
    
    always #5 clk_tb = ~clk_tb;
    
    initial begin
        clk_tb = 0;
        rst_tb = 1;
        load_tb = 0;
        instruction_in_tb = 12'b0;
        #10;
        
        rst_tb = 0;
        // Load instruction
        load_tb = 1;
        instruction_in_tb = 12'b0000_0110_0011;
        #10;
        
        // Load disabled: instruction should remain unchanged
        load_tb = 0;
        instruction_in_tb = 12'b1111_0011_0100;
        #10;
        
        // Load new instruction 
        load_tb = 1;
        instruction_in_tb = 12'b0110_1001_0001;
        #10;
        
        // Reset mid-operation
        rst_tb = 1;
        load_tb = 0;
        #10;
        rst_tb = 0;
        
        #20;
        $finish;
        end
endmodule
