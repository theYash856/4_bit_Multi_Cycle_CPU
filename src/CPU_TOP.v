`timescale 1ns / 1ps

module CPU_TOP(
    input clk,
    input rst,
    output halt
    );
    
    // PC 
    wire [3:0] pc_out;
    
    // Main Memory
    wire [11:0] mem_data_out; 
    
    // IR
    wire [11:0] IR_out;
    
    // CU
    wire pc_enable;       // Tells PC whether it should update
    wire ir_load;         // Tells IR to load new instruction 
    wire alu_enable;      // Allows ALU to perform computations
    wire reg_write;       // Allows Register File to store the ALU results
    wire jump_enable;     // Tells PC if jump instruction needed
    wire [3:0] alu_op;
    wire mem_read;        // LOAD operation
    wire mem_write;       // STORE operation  
    wire mem_to_reg;      // Select memory data vs ALU result for writeback
    
    // Register File
    wire [3:0] read_data1;
    wire [3:0] read_data2;
    
    // CPU's ALU
    wire [3:0] Y_final; 
    wire Cout;
    wire Z, N, V;
    
    // MUXes for dual purpose blocks
    // For slicing width written after name
    wire [3:0] mem_address = (mem_read | mem_write) ? IR_out[3:0] : pc_out; // Address input comes from PC or during LOAD/STORE
    wire [3:0] writeback_data = mem_to_reg ? mem_data_out[3:0] : Y_final; // Writeback to register comes from Memory or ALU result
    
    // Instantiating all the modules
    Program_Counter pc(.clk(clk), .rst(rst), .jump(jump_enable), .pc_enable(pc_enable), .jump_address(IR_out[3:0]), .pc(pc_out));
    
    Main_Memory mem(.clk(clk), .address(mem_address), .mem_write(mem_write), .data_in(read_data1), .data_out(mem_data_out));
    
    Instruction_Register ir(.clk(clk), .rst(rst), .load(ir_load), .instruction_in(mem_data_out), .instruction_out(IR_out));
    
    Control_Unit cu(.clk(clk), .rst(rst), .opcode(IR_out[11:8]), .pc_enable(pc_enable), .ir_load(ir_load), .alu_enable(alu_enable),
                    .reg_write(reg_write), .jump_enable(jump_enable), .alu_op(alu_op), .mem_read(mem_read), .mem_write(mem_write),
                    .mem_to_reg(mem_to_reg), .halt(halt));

    Register_File regi(.clk(clk), .rst(rst), .write_enable(reg_write), .write_address(IR_out[7:6]), .write_data(writeback_data),
                       .read_address1(IR_out[7:6]), .read_address2(IR_out[5:4]), .read_data1(read_data1), .read_data2(read_data2));
                       
    CPU_ALU cpu_alu(.A(read_data1), .B(read_data2), .alu_enable(alu_enable), .opcode_top(IR_out[11:8]), .Y_final(Y_final), .Cout(Cout),
                    .Z(Z), .N(N), .V(V));
endmodule
