`timescale 1ns / 1ps

module Control_Unit_tb;

    reg clk_tb, rst_tb;
    reg [3:0] opcode_tb;

    wire pc_enable_tb;
    wire ir_load_tb;
    wire alu_enable_tb;
    wire reg_write_tb;
    wire jump_enable_tb;
    wire [3:0] alu_op_tb;

    Control_Unit uut(.clk(clk_tb), .rst(rst_tb), .opcode(opcode_tb), .pc_enable(pc_enable_tb), .ir_load(ir_load_tb),
                     .alu_enable(alu_enable_tb), .reg_write(reg_write_tb), .jump_enable(jump_enable_tb), .alu_op(alu_op_tb));
    
    // Generates VCD waveform files for online EDA tools.
    initial begin
        $dumpfile("Control_Unit.vcd");
        $dumpvars(0, Control_Unit_tb);
    end
                         
    // Clock generation
    always #5 clk_tb = ~clk_tb;

    initial begin
        $monitor(
            "T=%0t ST=%b OPCODE=%b PE=%b IL=%b ALU_EN=%b RW=%b JE=%b ALU_OP=%b",
            $time,
            uut.current_state,
            opcode_tb,
            pc_enable_tb,
            ir_load_tb,
            alu_enable_tb,
            reg_write_tb,
            jump_enable_tb,
            alu_op_tb
        );
    end

    initial begin
        // Initialize signals
        clk_tb    = 0;
        rst_tb    = 1;
        opcode_tb = 4'b0100;   // ADD

        // Apply reset
        #10;
        rst_tb = 0;

        // Let ADD execute through one instruction cycle
        #40;

        // SUB
        opcode_tb = 4'b0101;
        #40;

        // AND
        opcode_tb = 4'b0000;
        #40;

        // JUMP
        opcode_tb = 4'b1110;
        #40;
        
        // HALT
        opcode_tb = 4'b1111;  
        #40;
        $finish;
    end
endmodule