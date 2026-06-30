`timescale 1ns / 1ps

module Control_Unit(
    input clk,
    input rst,
    input [3:0] opcode,
    
    // Output signals tells the CPU which operation to perform
    output reg pc_enable,       // Tells PC whether it should update
    output reg ir_load,         // Tells IR to load new instruction 
    output reg alu_enable,      // Allows ALU to perform computations
    output reg reg_write,       // Allows Register File to store the ALU results
    output reg jump_enable,     // Tells PC if jump instruction needed
    output reg [3:0] alu_op,
    output reg mem_read,        // LOAD operation
    output reg mem_write,       // STORE operation  
    output reg mem_to_reg,      // Select memory data vs ALU result for writeback
    output reg halt             // Stop execution
    );
    
    // FSM state encodings
    localparam FETCH     =   2'b00;
    localparam DECODE    =   2'b01;
    localparam EXECUTE   =   2'b10;
    localparam WRITEBACK =   2'b11;
    
    // Declaring state variables
    reg [1:0] current_state, next_state;
    
    // Sequential Register Block 
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end

    // Combinational next-state logic block
    always @(*) begin
        next_state = current_state; // Default
        case(current_state)
            FETCH: next_state = DECODE;
            DECODE: next_state = EXECUTE;
            EXECUTE: next_state = WRITEBACK;
            WRITEBACK: 
                if (opcode == 4'b1111)  
                    next_state = WRITEBACK; // If HALT then the program stops executing.
                else
                    next_state = FETCH;
            default:
                    next_state = FETCH;
        endcase
    end
    
    // Combinational output logic
    always @(*) begin
        pc_enable   = 0;
        ir_load     = 0;
        alu_enable  = 0;
        reg_write   = 0;
        jump_enable = 0;
        mem_read    = 0;
        mem_write   = 0;
        mem_to_reg  = 0;
        halt        = 0;
        alu_op      = 4'b0000;
        
        case(current_state)
            FETCH: ir_load = 1;
            DECODE: ; // Decoding happens internally, no signals triggered
            EXECUTE: begin
                     
                     if (opcode <= 4'b1011) begin
                        alu_enable = 1;
                        alu_op = opcode;
                        end
                     else begin
                          case(opcode)
                                4'b1100: mem_read = 1;      // LOAD
                                4'b1101: ;                  // STORE
                                4'b1110: jump_enable = 1;   // JUMP
                                4'b1111: ;                  // HALT handled in WRITEBACK
                          endcase
                          end
                     end
            WRITEBACK: begin
                         pc_enable = 1;
                         if (opcode <= 4'b1011) begin
                             alu_enable = 1;
                             reg_write = 1;
                         end
                         else begin
                             case(opcode)
                                 4'b1100: begin             // LOAD
                                     mem_read = 1;
                                     reg_write = 1;
                                     mem_to_reg = 1;
                                 end
                                 4'b1101: mem_write = 1;    // STORE 
                                 4'b1110: pc_enable = 0;    // JUMP
                                 4'b1111: begin             // HALT
                                     pc_enable = 0;
                                     halt = 1;
                                    end
                             endcase
                          end
                       end
            default: ;
        endcase
    end       
endmodule
