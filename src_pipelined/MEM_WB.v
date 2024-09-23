`timescale 1ns / 1ps
`include "diagv2_const.vh"

module MEM_WB(
    input clk,
    input reset,
    input [`RsltSrcBusBits-1:0] resultSrc_in,
    input regWrite_in,
    input ecall_in,
    input [`OpBusBits-1:0] op_in,
    input [`DataBusBits-1:0] ALUResult_in,
    input [`DataBusBits-1:0] readData_in,
    input [`DataBusBits-1:0] PCPlusImm_in,
    input [`RegAddrBits-1:0] writeReg_in,
    input [`DataBusBits-1:0] immExt_in,
    input [`DataBusBits-1:0] PCPlus4_in,
    output reg [`RsltSrcBusBits-1:0] resultSrc_out,
    output reg regWrite_out,
    output reg ecall_out,
    output reg [`OpBusBits-1:0] op_out,
    output reg [`DataBusBits-1:0] ALUResult_out,
    output reg [`DataBusBits-1:0] readData_out,
    output reg [`DataBusBits-1:0] PCPlusImm_out,
    output reg [`RegAddrBits-1:0] writeReg_out,
    output reg [`DataBusBits-1:0] immExt_out,
    output reg [`DataBusBits-1:0] PCPlus4_out
    );
    
    always @(posedge clk) begin
        if(reset) begin
            resultSrc_out <= `RsltSrcBusBits'b0;
            regWrite_out <= 1'b0;
            ecall_out <= 1'b0;
            op_out <= `OpBusBits'b0;
            ALUResult_out <= `DataZero;
            readData_out <= `DataZero;
            PCPlusImm_out <= `DataZero;
            writeReg_out <= `RegZero;
            immExt_out <= `DataZero;
            PCPlus4_out <= `DataZero;
        end
        else begin
            resultSrc_out <= resultSrc_in;
            regWrite_out <= regWrite_in;
            ecall_out <= ecall_in;
            op_out <= op_in;
            ALUResult_out <= ALUResult_in;
            readData_out <= readData_in;
            PCPlusImm_out <= PCPlusImm_in;
            writeReg_out <= writeReg_in;
            immExt_out <= immExt_in;
            PCPlus4_out <= PCPlus4_in;
        end
    end
    
endmodule
