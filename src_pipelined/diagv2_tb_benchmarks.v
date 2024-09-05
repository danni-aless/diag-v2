`timescale 1ns / 1ps
`include "diagv2_const.vh"

module diagv2_tb_benchmarks();

    parameter BMARKS = 10; // total benchmarks
    parameter BMARK_ID = 8; // benchmark to execute

    reg CLK, RESET, HALT;
    wire ecall;
    
    integer i, passed_tests, failed_tests;
    
    reg [103:0] riscv_tests[0:BMARKS-1] = {
        "median.mem",
        "qsort.mem",
        "rsort.mem",
        "towers.mem",
        "vvadd.mem",
        "memcpy.mem",
        "multiply.mem",
        "dhrystone.mem",
        "coremark.mem",
        "fib.mem"
    };
    
    reg [143:0] riscv_tests_data[0:BMARKS-1] = {
        "median_data.mem",
        "qsort_data.mem",
        "rsort_data.mem",
        "towers_data.mem",
        "vvadd_data.mem",
        "memcpy_data.mem",
        "multiply_data.mem",
        "dhrystone_data.mem",
        "coremark_data.mem",
        "fib_data.mem"
    };
    
    diagv2_top top(
        .clk(CLK),
        .reset(RESET),
        .ecall(ecall)
    );
	
    initial begin
        i = 0;
        passed_tests = 0;
        failed_tests = 0;
        CLK <= 1'b0;
        RESET <= 1'b1;
        HALT <= 1'b0;
        #10;
        $readmemh(riscv_tests[BMARK_ID], top.imem.imem); // write machine code to instruction memory
        $readmemh(riscv_tests_data[BMARK_ID], top.dmem.dmem); // write data to data memory
        #15;
        RESET <= 1'b0;
    end
    
    always begin // this block repeats forever
        #10 CLK <= ~(CLK ^ HALT); // HALT==0 -> CLK <= ~CLK, HALT==1 -> CLK <= CLK
    end
    
    wire [`DataBusBits-1:0] systemCall = top.core.reg_file.registers[17]; // a7/x17 register
    wire [`DataBusBits-1:0] arg0 = top.core.reg_file.registers[10]; // a0/x10 register
    
    reg [`DataBusBits-1:0] line; // where the null-terminated string is located
    integer offset;
    
    always @(negedge CLK) begin
        if(ecall) begin
            HALT <= 1'b1;
            $display("diagv2_tb (%s) - ECALL %2d", riscv_tests[BMARK_ID], systemCall);
            if(systemCall == 93) // EXIT ecall
            begin 
                $display("diagv2_tb (%s) - EXIT Status code: %2d", riscv_tests[BMARK_ID], arg0);
                $display("diagv2_tb (%s) - Benchmark ended at time: %t", riscv_tests[BMARK_ID], $realtime);
            end 
            else if(systemCall == 4) // PRINT ecall
            begin 
                line = arg0>>3;
                offset = arg0[2:0];
                while(top.dmem.dmem[line][offset*8+:8] != 8'b0) begin
                    $write("%c", top.dmem.dmem[line][offset*8+:8]);
                    offset = offset+1;
                    if(offset == 8) begin
                        line = line+1;
                        offset = 0;
                    end
                end
                HALT <= 1'b0;
            end 
            else // invalid ecall
                $display("diagv2_tb (%s) - ECALL not valid", riscv_tests[BMARK_ID]);
        end
    end

endmodule
