`timescale 1ns / 1ps

module CPU_ALU(
    input [3:0] A,
    input [3:0] B,
    input [3:0] opcode_top,
    input alu_enable,

    output reg [3:0] Y_final,
    output reg Cout,
    output reg Z,
    output reg N,
    output reg V
    );
    
    reg [2:0] opcode_alu;
    wire [3:0]Y_temp;
    wire Cout_temp;
    
    // Opcode Translation
    always @(*) begin
        case(opcode_top)
            4'b0000: opcode_alu = 3'b000; // AND
            4'b0001: opcode_alu = 3'b001; // OR
            4'b0010: opcode_alu = 3'b010; // NOT
            4'b0011: opcode_alu = 3'b100; // XOR
            4'b0100: opcode_alu = 3'b110; // ADD
            4'b0101: opcode_alu = 3'b111; // SUB
            default: opcode_alu = 3'b000;
        endcase
    end
    
    // To instantiate we use part select to match the width of the opcode of 4_bit and outputs are stored in temporary variables.
    ALU_4_bit alu_cpu(.A_4bit(A), .B_4bit(B), .opcode_4bit(opcode_alu), .Y_4bit(Y_temp), .Cout(Cout_temp));
    
    always @(*) begin
        Y_final = 4'b0000;
        Cout    = 0;
        Z       = 0;
        N       = 0;
        V       = 0;
        if (alu_enable) begin
            Y_final = Y_temp; // Default to cover 0-7 cases   
            Cout = Cout_temp; // Default to cover ADD and SUB 
        
            case(opcode_top)
                // Shift operators 
                4'b0110: begin Y_final = A<<1; Cout = 0; end //Shift Left Logical (SLL)
                4'b0111: begin Y_final = A>>1; Cout = 0; end //Shift Right Logical (SRL)
            
                // Comparison operators 
                4'b1000: begin Y_final = (A==B); Cout = 0; end // Set Equal (SEQ)
                4'b1001: begin Y_final = (A<B); Cout = 0; end // Set Less Than (SLT)
                4'b1010: begin Y_final = (A>B); Cout = 0; end // Set Greater Than (SGT)
            
                //Increment
                4'b1011: begin Y_final = A+1; Cout = 0; end
            
                default: ;
            endcase
        
            // Flags are used by the CPU control unit to make decisions after an ALU operation.
            Z = (Y_final == 4'b0000);  // Zero Flag
            N = Y_final[3];            // Negative Flag
        
            V = ((opcode_top == 4'b0100) && (A[3] == B[3]) && (Y_final[3] != A[3])) ||  // Checks for ADD
                ((opcode_top == 4'b0101) && (A[3] != B[3]) && (Y_final[3] != A[3]));    // Checks for SUB
        end
    end
endmodule
