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
    output ecall // signal for testing/debugging
    );
    
    // signals
    wire regWrite, ALUSrc, ALU32;
    wire [`PCSrcBusBits-1:0] PCSrc;
    wire [`ImmSrcBusBits-1:0] immSrc;
    wire [`AluCntrBusBits-1:0] ALUControl;
    wire [`RsltSrcBusBits-1:0] resultSrc;
    
    wire [`DataBusBits-1:0] PCPlus4, PCPlusImm;
    reg [`DataBusBits-1:0] PCNext;
    
    wire [`OpBusBits-1:0] op;
    wire [`Funct3BusBits-1:0] funct3;
    wire [`Funct7BusBits-1:0] funct7;

    wire [`RegAddrBits-1:0] readRegister1, readRegister2, writeRegister;
    wire [`DataBusBits-1:0] readData1, readData2;
    reg  [`DataBusBits-1:0] writeDataReg;
    
    wire [`DataBusBits-1:0] immExt;
    
    wire [`DataBusBits-1:0] srcA;
    reg [`DataBusBits-1:0] srcB;
    wire zero, lt, ltu; // ALU signals
    
    assign op = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    
    assign readRegister1 = instr[19:15];
    assign readRegister2 = instr[24:20];
    assign writeRegister = instr[11:7];
    assign srcA = readData1;
    
    assign writeData = readData2;
    
    always @(posedge clk) begin
        //$display("Instruction %h: %h", PCF, instrF);
    end
    
    always @(*) begin
        case(ALUSrc) // for signal B of ALU
            1'b0: srcB = readData2; // BRANCH, OP(_32)
            1'b1: srcB = immExt;    // JALR, LOAD, STORE, OP_IMM(_32)
        endcase
        case(resultSrc) // for signal writeData of Register File
            3'b000: writeDataReg = ALUResult;  // OP(_32), OP_IMM(_32)
            3'b001: writeDataReg = readData;   // LOAD
            3'b010: writeDataReg = PCPlus4;    // JAL, JALR
            3'b011: writeDataReg = immExt;     // LUI
            default: writeDataReg = PCPlusImm; // AUIPC
        endcase
        case(PCSrc) // for signal PCNext of PC
            2'b00: PCNext = PCPlus4;     // BRANCH (not taken)
            2'b01: PCNext = PCPlusImm;   // JAL, BRANCH (taken)
            default: PCNext = ALUResult; // JALR
        endcase
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
        .readData2(readData2)
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
