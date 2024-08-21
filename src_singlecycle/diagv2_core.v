`timescale 1ns / 1ps
`include "diagv2_const.vh"

module diagv2_core(
    input clk,
    input reset,
    input [`InstrBusBits-1:0] instr,
    input [`DataBusBits-1:0] readData,
    output [`DataBusBits-1:0] PC,
    output [`DataBusBits-1:0] ALUResult,
    output [`DataBusBits-1:0] writeData,
    output memWrite, // signal for dmem
    output [`MemTypeBusBits-1:0] memType, // signal for dmem
    output ecall, // signal for testing/debugging
    output [`DataBusBits-1:0] statusCode // x10 register
    );
    
    // signals
    wire regWrite, ALUSrc, ALU32;
    wire [`PCSrcBusBits-1:0] PCSrc;
    wire [`ImmSrcBusBits-1:0] immSrc;
    wire [`AluCntrBusBits-1:0] ALUControl;
    wire [`RsltSrcBusBits-1:0] resultSrc;
    
    wire [`DataBusBits-1:0] PCNext, PCPlus4, PCPlusImm;
    
    wire [`OpBusBits-1:0] op;
    wire [`Funct3BusBits-1:0] funct3;
    wire [`Funct7BusBits-1:0] funct7;

    wire [`RegAddrBits-1:0] readRegister1, readRegister2, writeRegister;
    wire [`DataBusBits-1:0] readData1, readData2, writeDataReg;
    
    wire [`DataBusBits-1:0] immExt;
    
    wire [`DataBusBits-1:0] srcA, srcB;
    wire zero, lt, ltu; // ALU signals
    
    assign PCNext = PCSrc[1] ? ALUResult : (PCSrc[0] ? PCPlusImm : PCPlus4);
    
    assign op = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    
    assign readRegister1 = instr[19:15];
    assign readRegister2 = instr[24:20];
    assign writeRegister = instr[11:7];
    assign writeDataReg  = resultSrc[2] ? PCPlusImm :
                           resultSrc[1] ? (resultSrc[0] ? immExt : PCPlus4) 
                                        : (resultSrc[0] ? readData : ALUResult);
    assign srcA = readData1;
    assign srcB = ALUSrc ? immExt : readData2;
    
    assign writeData = readData2;
    
    always @(posedge clk) begin
        //$display("Instruction %h: %h", PCF, instrF);
    end

    pc pc_reg(
        .clk(clk),
        .reset(reset),
        .PCNext(PCNext),
        .PC(PC)
    );
    
    adder pc_adder(
        .in_1(PC),
        .in_2(`DataBusBits'd4),
        .out(PCPlus4)
    );
    
    control_unit cu(
        .op(op),
        .funct3(funct3),
        .funct7(funct7),
        .zero(zero),
        .lt(lt),
        .ltu(ltu),
        .PCSrc(PCSrc),
        .regWrite(regWrite),
        .immSrc(immSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .ALU32(ALU32),
        .memWrite(memWrite),
        .memType(memType),
        .resultSrc(resultSrc),
        .ecall(ecall)
    );
    
    register_file reg_file(
        .clk(clk),
        .reset(reset),
        .we(regWrite),
        .readRegister1(readRegister1),
        .readRegister2(readRegister2),
        .writeRegister(writeRegister),
        .writeData(writeDataReg),
        .readData1(readData1),
        .readData2(readData2),
        .statusCode(statusCode)
    );
    
    imm_generator imm_gen(
        .instr(instr),
        .immSrc(immSrc),
        .immExt(immExt)
    );
    
    alu alu(
        .ALU32(ALU32),
        .ALUControl(ALUControl),
        .A(srcA),
        .B(srcB),
        .out(ALUResult),
        .zero(zero),
        .lt(lt),
        .ltu(ltu)
    );
    
    adder branch_adder(
        .in_1(PC),
        .in_2(immExt),
        .out(PCPlusImm)
    );
    
endmodule
