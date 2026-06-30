`timescale 1ns / 1ps

module CPU_ALU_tb;
    reg [3:0] A_tb, B_tb;
    reg [3:0] opcode_top_tb;
    reg alu_enable_tb;
    
    wire [3:0] Y_final_tb;
    wire Cout_tb;
    wire Z_tb, N_tb, V_tb;
    
    CPU_ALU uut(.A(A_tb), .B(B_tb), .opcode_top(opcode_top_tb), .alu_enable(alu_enable_tb), .Y_final(Y_final_tb), 
                .Cout(Cout_tb), .Z(Z_tb), .N(N_tb), .V(V_tb));
    
    // Generates VCD waveform files for online EDA tools.
    initial begin
        $dumpfile("CPU_ALU.vcd");
        $dumpvars(0, CPU_ALU_tb);
    end
    
    initial begin
        A_tb = 0;
        B_tb = 0;
        opcode_top_tb = 0;
        alu_enable_tb = 1;
        
        $display("op   |  A   |   B  |   Y  | C Z N V");
        $display("------------------------------------");
        $monitor("%b | %b | %b | %b | %b %b %b %b",
                  opcode_top_tb, A_tb, B_tb, Y_final_tb, Cout_tb, Z_tb, N_tb, V_tb);
        
        // AND 
        A_tb=4'b1010; B_tb=4'b1100; opcode_top_tb=4'b0000; #10;
        
        // OR 
        A_tb=4'b1010; B_tb=4'b1100; opcode_top_tb=4'b0001; #10;
        
        // NOT 
        A_tb=4'b1010; B_tb=4'bxxxx; opcode_top_tb=4'b0010; #10;
        
        // XOR 
        A_tb=4'b1010; B_tb=4'b1100; opcode_top_tb=4'b0011; #10;
        
        
        // ADD - normal 
        A_tb=4'b0011; B_tb=4'b0101; opcode_top_tb=4'b0100; #10;
        
        // ADD - overflow 
        A_tb=4'b0111; B_tb=4'b0001; opcode_top_tb=4'b0100; #10;
        
        // SUB - normal 
        A_tb=4'b0101; B_tb=4'b0011; opcode_top_tb=4'b0101; #10;
        
        // SUB - borrow 
        A_tb=4'b0011; B_tb=4'b0101; opcode_top_tb=4'b0101; #10;
        
        // SLL 
        A_tb=4'b0011; B_tb=4'bxxxx; opcode_top_tb=4'b0110; #10;
        
        // SRL 
        A_tb=4'b1100; B_tb=4'bxxxx; opcode_top_tb=4'b0111; #10;
        
        // SEQ - true 
        A_tb=4'b0101; B_tb=4'b0101; opcode_top_tb=4'b1000; #10;
        
        // SEQ - false 
        A_tb=4'b0101; B_tb=4'b0011; opcode_top_tb=4'b1000; #10;
        
        // SLT 
        A_tb=4'b0011; B_tb=4'b0101; opcode_top_tb=4'b1001; #10;
        
        // SGT 
        A_tb=4'b0101; B_tb=4'b0011; opcode_top_tb=4'b1010; #10;
        
        // INC
        A_tb=4'b0101; B_tb=4'bxxxx; opcode_top_tb=4'b1011; #10;
        
        $finish;
    end
endmodule
