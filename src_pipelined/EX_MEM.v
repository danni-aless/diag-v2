`timescale 1ns / 1ps
`include "diagv2_const.vh"

module EX_MEM(
    input clk,
    input reset,
    input memWrite_in,
    input [`MemTypeBusBits-1:0] memType_in,
    input [`RsltSrcBusBits-1:0] resultSrc_in,
    input regWrite_in,
    input [`DataBusBits-1:0] ALUResult_in,
    input [`DataBusBits-1:0] writeData_in,
    input [`DataBusBits-1:0] PCTarget_in,
    input [`RegAddrBits-1:0] writeReg_in,
    input [`DataBusBits-1:0] immExt_in,
    input [`DataBusBits-1:0] PCPlus4_in,
    output reg memWrite_out,
    output reg [`MemTypeBusBits-1:0] memType_out,
    output reg [`RsltSrcBusBits-1:0] resultSrc_out,
    output reg regWrite_out,
    output reg [`DataBusBits-1:0] ALUResult_out,
    output reg [`DataBusBits-1:0] writeData_out,
    output reg [`DataBusBits-1:0] PCTarget_out,
    output reg [`RegAddrBits-1:0] writeReg_out,
    output reg [`DataBusBits-1:0] immExt_out,
    output reg [`DataBusBits-1:0] PCPlus4_out
    );
    
    always @(posedge clk) begin
        if(reset) begin
            memWrite_out <= 1'b0;
            memType_out <= `MemTypeBusBits'b0;
            resultSrc_out <= `RsltSrcBusBits'b0;
            regWrite_out <= 1'b0;
            ALUResult_out <= `DataZero;
            writeData_out <= `DataZero;
            PCTarget_out <= `DataZero;
            writeReg_out <= `RegZero;
            immExt_out <= `DataZero;
            PCPlus4_out <= `DataZero;
        end
        else begin
            memWrite_out <= memWrite_in;
            memType_out <= memType_in;
            resultSrc_out <= resultSrc_in;
            regWrite_out <= regWrite_in;
            ALUResult_out <= ALUResult_in;
            writeData_out <= writeData_in;
            PCTarget_out <= PCTarget_in;
            writeReg_out <= writeReg_in;
            immExt_out <= immExt_in;
            PCPlus4_out <= PCPlus4_in;
        end
    end
    
endmodule
