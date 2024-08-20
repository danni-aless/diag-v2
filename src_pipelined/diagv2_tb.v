`timescale 1ns / 1ps
`include "diagv2_const.vh"

module diagv2_tb();

    reg CLK, RESET, HALT;
    wire ecall;
    wire [`DataBusBits-1:0] statusCode; // x10 register
    
    reg [79:0] riscv_tests[0:38] = {
        "add.mem",
        "addi.mem",
        "addiw.mem",
        "addw.mem",
        "and.mem",
        "andi.mem",
        "auipc.mem",
        "beq.mem",
        "bge.mem",
        "bgeu.mem",
        "blt.mem",
        "bltu.mem",
        "bne.mem",
        "jal.mem",
        "jalr.mem",
        "lui.mem",
        "or.mem",
        "ori.mem",
        "simple.mem",
        "sll.mem",
        "slli.mem",
        "slliw.mem",
        "sllw.mem",
        "slt.mem",
        "slti.mem",
        "sltiu.mem",
        "sltu.mem",
        "sra.mem",
        "srai.mem",
        "sraiw.mem",
        "sraw.mem",
        "srl.mem",
        "srli.mem",
        "srliw.mem",
        "srlw.mem",
        "sub.mem",
        "subw.mem",
        "xor.mem",
        "xori.mem"
    };
    
    /*reg [79:0] riscv_tests[0:49] = {
        "add.mem",
        "addi.mem",
        "addiw.mem",
        "addw.mem",
        "and.mem",
        "andi.mem",
        "auipc.mem",
        "beq.mem",
        "bge.mem",
        "bgeu.mem",
        "blt.mem",
        "bltu.mem",
        "bne.mem",
        "jal.mem",
        "jalr.mem",
        "lb.mem",
        "lbu.mem",
        "ld.mem",
        "lh.mem",
        "lhu.mem",
        "lui.mem",
        "lw.mem",
        "lwu.mem",
        "or.mem",
        "ori.mem",
        "sb.mem",
        "sd.mem",
        "sh.mem",
        "simple.mem",
        "sll.mem",
        "slli.mem",
        "slliw.mem",
        "sllw.mem",
        "slt.mem",
        "slti.mem",
        "sltiu.mem",
        "sltu.mem",
        "sra.mem",
        "srai.mem",
        "sraiw.mem",
        "sraw.mem",
        "srl.mem",
        "srli.mem",
        "srliw.mem",
        "srlw.mem",
        "sub.mem",
        "subw.mem",
        "sw.mem",
        "xor.mem",
        "xori.mem"
    };*/
    
    integer i, passed_tests, failed_tests;

    diagv2_top top(
        .clk(CLK),
        .reset(RESET),
        .ecall(ecall),
        .statusCode(statusCode)
    );
	
    initial begin
        i = 0;
        passed_tests = 0;
        failed_tests = 0;
        $readmemh(riscv_tests[i], top.imem.imem);
        $readmemh(riscv_tests[i], top.dmem.dmem);
        CLK <= 1'b0;
        RESET <= 1'b1;
        HALT <= 1'b0;
        #20;
        RESET <= 1'b0;
    end
    
    always begin // this block repeats forever
        #10 CLK <= ~(CLK ^ HALT); // HALT==0 -> CLK <= ~CLK, HALT==1 -> CLK <= CLK
    end
    
    always @(negedge CLK) begin
        if(ecall) begin
            $display("diagv2_tb (%s) - ECALL Status code: %2d", riscv_tests[i], statusCode);
            HALT <= 1'b1;
            if(!statusCode)
                passed_tests = passed_tests+1;
            else
                failed_tests = failed_tests+1;
            i = i+1;
            if(i<39) begin
                $readmemh(riscv_tests[i], top.imem.imem);
                $readmemh(riscv_tests[i], top.dmem.dmem);
                RESET <= 1'b1;
                HALT <= 1'b0;
                #20;
                RESET <= 1'b0;
            end
            else
                $display("diagv2_tb - Passed tests: %2d, failed tests: %2d", passed_tests, failed_tests);
        end
    end

endmodule
