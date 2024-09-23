`timescale 1ns / 1ps
`include "diagv2_const.vh"

module ID_EX(
    input clk,
    input reset,
    input [`Funct3BusBits-1:0] funct3_in,
    input ALUSrc_in, ALU32_in,
    input [`AluCntrBusBits-1:0] ALUControl_in,
    input jal_in, jalr_in, branch_in,
    input memWrite_in,
    input [`MemTypeBusBits-1:0] memType_in,
    input [`RsltSrcBusBits-1:0] resultSrc_in,
    input regWrite_in,
    input ecall_in,
    input csrrs_in,
    input [`OpBusBits-1:0] op_in,
    input [`DataBusBits-1:0] readData1_in, readData2_in,
    input [`DataBusBits-1:0] PC_in,
    input [`RegAddrBits-1:0] readRegister1_in, readRegister2_in,
    input [`RegAddrBits-1:0] writeReg_in,
    input [`DataBusBits-1:0] immExt_in,
    input [`DataBusBits-1:0] PCPlus4_in,
    output reg [`Funct3BusBits-1:0] funct3_out,
    output reg ALUSrc_out, ALU32_out,
    output reg [`AluCntrBusBits-1:0] ALUControl_out,
    output reg jal_out, jalr_out, branch_out,
    output reg memWrite_out,
    output reg [`MemTypeBusBits-1:0] memType_out,
    output reg [`RsltSrcBusBits-1:0] resultSrc_out,
    output reg regWrite_out,
    output reg ecall_out,
    output reg csrrs_out,
    output reg [`OpBusBits-1:0] op_out,
    output reg [`DataBusBits-1:0] readData1_out, readData2_out,
    output reg [`DataBusBits-1:0] PC_out,
    output reg [`RegAddrBits-1:0] readRegister1_out, readRegister2_out,
    output reg [`RegAddrBits-1:0] writeReg_out,
    output reg [`DataBusBits-1:0] immExt_out,
    output reg [`DataBusBits-1:0] PCPlus4_out
    );
    
    always @(posedge clk) begin
        if(reset) begin
            funct3_out <= `Funct3BusBits'b0;
            ALUSrc_out <= 1'b0;
            ALU32_out <= 1'b0;
            ALUControl_out <= `AluCntrBusBits'b0;
            jal_out <= 1'b0;
            jalr_out <= 1'b0;
            branch_out <= 1'b0;
            memWrite_out <= 1'b0;
            memType_out <= `MemTypeBusBits'b0;
            resultSrc_out <= `RsltSrcBusBits'b0;
            regWrite_out <= 1'b0;
            ecall_out <= 1'b0;
            csrrs_out <= 1'b0;
            op_out <= `OpBusBits'b0;
            readData1_out <= `DataZero;
            readData2_out <= `DataZero;
            PC_out <= `DataZero;
            readRegister1_out <= `RegZero;
            readRegister2_out <= `RegZero;
            writeReg_out <= `RegZero;
            immExt_out <= `DataZero;
            PCPlus4_out <= `DataZero;
        end
        else begin
            funct3_out <= funct3_in;
            ALUSrc_out <= ALUSrc_in;
            ALU32_out <= ALU32_in;
            ALUControl_out <= ALUControl_in;
            jal_out <= jal_in;
            jalr_out <= jalr_in;
            branch_out <= branch_in;
            memWrite_out <= memWrite_in;
            memType_out <= memType_in;
            resultSrc_out <= resultSrc_in;
            regWrite_out <= regWrite_in;
            ecall_out <= ecall_in;
            csrrs_out <= csrrs_in;
            op_out <= op_in;
            readData1_out <= readData1_in;
            readData2_out <= readData2_in;
            PC_out <= PC_in;
            readRegister1_out <= readRegister1_in;
            readRegister2_out <= readRegister2_in;
            writeReg_out <= writeReg_in;
            immExt_out <= immExt_in;
            PCPlus4_out <= PCPlus4_in;
        end
    end
    
endmodule
