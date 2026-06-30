`timescale 1ns / 1ps

module Register_File_tb;

    reg clk_tb, rst_tb, write_enable_tb;
    reg [1:0] write_address_tb,read_address1_tb, read_address2_tb;
    reg [3:0] write_data_tb;
    
    wire [3:0] read_data1_tb, read_data2_tb;
    
    Register_File uut(.clk(clk_tb), .rst(rst_tb), .write_enable(write_enable_tb), .write_address(write_address_tb),
                      .write_data(write_data_tb), .read_address1(read_address1_tb), .read_address2(read_address2_tb),
                      .read_data1(read_data1_tb), .read_data2(read_data2_tb));
    
    // Generates VCD waveform files for online EDA tools.
    initial begin
        $dumpfile("Register_File.vcd");
        $dumpvars(0, Register_File_tb);
    end
    
    always #5 clk_tb = ~clk_tb;
    
    initial begin
        clk_tb = 0;
        rst_tb = 1;
        write_enable_tb = 0;
        write_address_tb = 0;
        write_data_tb = 0;
        read_address1_tb = 0;
        read_address2_tb = 0;
        #10;
        rst_tb = 0;
        
        
        // Write to R1
        write_enable_tb = 1;
        write_address_tb = 2'b01;
        write_data_tb = 4'b1010;
        #10;
        
        // Write to R2
        write_address_tb = 2'b10;
        write_data_tb = 4'b0110;
        #10;
        
        write_enable_tb = 0;
        
        // Read R1 and R2
        read_address1_tb = 2'b01;
        read_address2_tb = 2'b10;
        #10;
        
        // Writing with write_enable = 0 (should NOT update)
        write_enable_tb = 0;
        write_address_tb = 2'b01;
        write_data_tb = 4'b1111;  // different value
        #10;
        read_address1_tb = 2'b01; // Should be 1010
        #10;
        
        // Reset verification
        rst_tb = 1;
        #10;
        rst_tb = 0;
        
        // Verify registers are cleared after reset
        read_address1_tb = 2'b01;
        read_address2_tb = 2'b10;
        #10;
        
        $finish;
        end
                          
endmodule
