`timescale 1ns / 1ps
`include "diagv2_const.vh"

module diagv2_tb_isa();

    parameter TESTS = 50;

    reg CLK, RESET, HALT;
    wire ecall;
    
    integer i, passed_tests, failed_tests;
    
    reg [79:0] riscv_tests[0:TESTS-1] = {
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
    };
    
    reg [119:0] riscv_tests_data[0:TESTS-1] = {
        "add_data.mem",
        "addi_data.mem",
        "addiw_data.mem",
        "addw_data.mem",
        "and_data.mem",
        "andi_data.mem",
        "auipc_data.mem",
        "beq_data.mem",
        "bge_data.mem",
        "bgeu_data.mem",
        "blt_data.mem",
        "bltu_data.mem",
        "bne_data.mem",
        "jal_data.mem",
        "jalr_data.mem",
        "lb_data.mem",
        "lbu_data.mem",
        "ld_data.mem",
        "lh_data.mem",
        "lhu_data.mem",
        "lui_data.mem",
        "lw_data.mem",
        "lwu_data.mem",
        "or_data.mem",
        "ori_data.mem",
        "sb_data.mem",
        "sd_data.mem",
        "sh_data.mem",
        "simple_data.mem",
        "sll_data.mem",
        "slli_data.mem",
        "slliw_data.mem",
        "sllw_data.mem",
        "slt_data.mem",
        "slti_data.mem",
        "sltiu_data.mem",
        "sltu_data.mem",
        "sra_data.mem",
        "srai_data.mem",
        "sraiw_data.mem",
        "sraw_data.mem",
        "srl_data.mem",
        "srli_data.mem",
        "srliw_data.mem",
        "srlw_data.mem",
        "sub_data.mem",
        "subw_data.mem",
        "sw_data.mem",
        "xor_data.mem",
        "xori_data.mem"
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
        $readmemh(riscv_tests[i], top.imem.imem); // write machine code to instruction memory
        $readmemh(riscv_tests_data[i], top.dmem.dmem); // write data to data memory
        #15;
        RESET <= 1'b0;
    end
    
    always begin // this block repeats forever
        #10 CLK <= ~(CLK ^ HALT); // HALT==0 -> CLK <= ~CLK, HALT==1 -> CLK <= CLK
    end
    
    wire [`DataBusBits-1:0] systemCall = top.core.reg_file.registers[17]; // a7/x17 register
    wire [`DataBusBits-1:0] arg0 = top.core.reg_file.registers[10]; // a0/x10 register
    
    always @(negedge CLK) begin
        if(ecall) begin
            HALT <= 1'b1;
            // $display("diagv2_tb (%s) - ECALL %2d", riscv_tests[i], systemCall);
            if(systemCall == 93) // EXIT ecall
            begin
                $display("diagv2_tb (%s) - EXIT Status code: %2d", riscv_tests[i], arg0);
                if(!arg0)
                    passed_tests = passed_tests+1;
                else
                    failed_tests = failed_tests+1;
                i = i+1;
                if(i<TESTS) begin
                    RESET <= 1'b1;
                    HALT <= 1'b0;
                    #10;
                    $readmemh(riscv_tests[i], top.imem.imem);
                    $readmemh(riscv_tests_data[i], top.dmem.dmem);
                    #15;
                    RESET <= 1'b0;
                end
                else
                    $display("diagv2_tb - Passed tests: %2d, failed tests: %2d", passed_tests, failed_tests);
            end
            else // invalid ecall
                $display("diagv2_tb (%s) - ECALL not valid", riscv_tests[i]);
        end
    end

endmodule
