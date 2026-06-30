`timescale 1ns / 1ps

module CPU_TOP_tb;
    reg clk_tb;
    reg rst_tb;
    wire halt_tb;
    
    CPU_TOP uut(.clk(clk_tb), .rst(rst_tb), .halt(halt_tb));
    
    // Generates VCD waveform files for online EDA tools and external waveform viewers.
    initial begin
        $dumpfile("CPU_TOP.vcd");
        $dumpvars(0, CPU_TOP_tb);
    end
    
    // 10 ns clock period
    always #5 clk_tb = ~clk_tb;
    
    // Apply reset at the beginning of simulation
    initial begin
        clk_tb = 0;
        rst_tb = 1;
        #10;
        rst_tb = 0;
    end
    
    initial begin
        $display("TIME | ST |  PC  |      IR      | PE | IL | MR | MW | MT | RW | JE | ADDR |  R0  |  R1  |  WB  | ALU  | H");
    $display("----------------------------------------------------------------------------------------------------------");
        $monitor("%-4d | %-2b | %-4b | %-12b | %-1b  | %-1b  | %-1b  | %-1b  | %-1b  | %-1b  | %-1b  | %-4b | %-4b | %-4b | %-4b | %-4b | %-1b",
            $time,
            uut.cu.current_state,   // ST  - FSM state
            uut.pc_out,             // PC
            uut.IR_out,             // IR
            uut.pc_enable,          // PE
            uut.ir_load,            // IL
            uut.mem_read,           // MR
            uut.mem_write,          // MW
            uut.mem_to_reg,         // MT
            uut.reg_write,          // RW
            uut.jump_enable,        // JE
            uut.mem_address,        // ADDR
            uut.regi.registers[0],  // R0
            uut.regi.registers[1],  // R1
            uut.writeback_data,     // WB
            uut.Y_final,            // ALU
            halt_tb);               // H
        
        // Wait until the HALT instruction terminates execution    
        wait(halt_tb);
        #20;
        
        $display("\n--- Final Register State ---");
        $display("R0 = %b (%0d)", uut.regi.registers[0], uut.regi.registers[0]);
        $display("R1 = %b (%0d)", uut.regi.registers[1], uut.regi.registers[1]);
        $display("R2 = %b (%0d)", uut.regi.registers[2], uut.regi.registers[2]);
        $display("R3 = %b (%0d)", uut.regi.registers[3], uut.regi.registers[3]);
        $display("\n--- Final Memory Contents ---");
        $display("Memory[11] = %b (%0d)", uut.mem.memory[11], uut.mem.memory[11]);
        $display("Memory[12] = %b (%0d)", uut.mem.memory[12], uut.mem.memory[12]);
        $display("Memory[14] = %b (%0d)", uut.mem.memory[14], uut.mem.memory[14]);
        $finish;
    end
endmodule