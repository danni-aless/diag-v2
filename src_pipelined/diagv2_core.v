`timescale 1ns / 1ps
`include "diagv2_const.vh"

module diagv2_core(
    input clk,
    input reset,
    input [`InstrBusBits-1:0] instrF,
    input [`DataBusBits-1:0] readDataM,
    output [`DataBusBits-1:0] PCF,
    output [`DataBusBits-1:0] ALUResultM,
    output [`DataBusBits-1:0] writeDataM,
    output memWriteM, // signal for dmem
    output [`MemTypeBusBits-1:0] memTypeM, // signal for dmem
    output ecallW // signal for testing/debugging
    );
    
    // control signals
    wire csrrsD, csrrsE; // signal for reading mcycle and minstret
    wire [`ImmSrcBusBits-1:0] immSrc;
    wire ALUSrcD, ALUSrcE;
    wire [`AluCntrBusBits-1:0] ALUControlD, ALUControlE;
    wire ALU32D, ALU32E;
    wire jalD, jalrD, branchD, jalE, jalrE, branchE;
    wire memWriteD, memWriteE;
    wire [`MemTypeBusBits-1:0] memTypeD, memTypeE;
    wire [`RsltSrcBusBits-1:0] resultSrcD, resultSrcE, resultSrcM, resultSrcW;
    wire regWriteD, regWriteE, regWriteM, regWriteW;
    wire ecallD, ecallE, ecallM;
    
    // hazard signals
    wire PCSrc;
    wire stallF, stallD;
    wire flushD, flushE;
    wire [`ForwardBusBits-1:0] forwardAE, forwardBE;

    wire [`DataBusBits-1:0] PCNextF, PCNextE;
    wire [`DataBusBits-1:0] PCD, PCE;
    wire [`DataBusBits-1:0] PCPrediction;
    wire [`DataBusBits-1:0] PCPlus4F, PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W;
    
    wire [`InstrBusBits-1:0] instrD;
    wire [`OpBusBits-1:0] opD, opE, opM, opW;
    wire [`Funct3BusBits-1:0] funct3D, funct3E;
    wire [`Funct7BusBits-1:0] funct7;
    wire [`RegAddrBits-1:0] readRegister1D, readRegister1E;
    wire [`RegAddrBits-1:0] readRegister2D, readRegister2E;
    wire [`CSRAddrBits-1:0] readCSR;
    wire [`RegAddrBits-1:0] writeRegD, writeRegE, writeRegM, writeRegW;
    wire [`DataBusBits-1:0] writeDataReg;
    wire [`DataBusBits-1:0] readData1D, readData1E;
    wire [`DataBusBits-1:0] readData2D, readData2E;
    wire [`DataBusBits-1:0] immExtD, immExtE, immExtM, immExtW;
    
    wire [`DataBusBits-1:0] srcA, srcB;
    wire [`DataBusBits-1:0] ALUResultE, ALUResultW;
    wire zero, lt, ltu; // ALU signals
    wire [`DataBusBits-1:0] writeDataE;
    wire [`DataBusBits-1:0] PCPlusImmE, PCPlusImmM, PCPlusImmW;
    wire branchOp, taken;
    
    wire [`DataBusBits-1:0] forwardingMtoE;
    
    wire [`DataBusBits-1:0] readDataW;
    
    // FETCH
    assign PCNextF = PCSrc ? PCPrediction : PCNextE;
    
    // DECODE
    assign opD = instrD[6:0];
    assign funct3D = instrD[14:12];
    assign funct7 = instrD[31:25];
    assign readRegister1D = instrD[19:15];
    assign readRegister2D = instrD[24:20];
    assign readCSR = instrD[31:20];
    assign writeRegD = instrD[11:7];
    
    // EXECUTE
    assign srcA = forwardAE[1] ? forwardingMtoE :
                  forwardAE[0] ? writeDataReg : readData1E;
    assign writeDataE = forwardBE[1] ? forwardingMtoE :
                        forwardBE[0] ? writeDataReg : readData2E;
    assign srcB = ALUSrcE ? immExtE : writeDataE;
    
    // MEMORY
    assign forwardingMtoE = resultSrcM[2] ? PCPlusImmM : 
                            resultSrcM[1] ? (resultSrcM[0] ? immExtM : PCPlus4M) 
                                          : (resultSrcM[0] ? `DataZero : ALUResultM);
    
    // WRITEBACK
    assign writeDataReg = resultSrcW[2] ? PCPlusImmW : 
                          resultSrcW[1] ? (resultSrcW[0] ? immExtW : PCPlus4W) 
                                        : (resultSrcW[0] ? readDataW : ALUResultW);
    
    always @(posedge clk) begin
        //$display("Instruction %h: %h", PCF, instrF);
    end
    
    pc pc_reg(
        .clk(clk),
        .reset(reset),
        .we(~stallF), // stalling for load hazard
        .PCNext(PCNextF),
        .PC(PCF)
    );
    
    branch_predictor_tournament bp(
        .clk(clk),
        .reset(reset),
        .we(branchOp), // write when instruction is jal, jalr, or branch
        .PC(PCF),
        .PCUpdate(PCE),
        .targetUpdate(PCNextE),
        .takenUpdate(taken),
        .PCPlus4(PCPlus4F),
        .PCPrediction(PCPrediction)
    );
    
    IF_ID if_id_reg(
        .clk(clk),
        .reset(reset | flushD), // flushing for control hazard
        .we(~stallD), // stalling for load hazard
        .instr_in(instrF),
        .PC_in(PCF),
        .PCPlus4_in(PCPlus4F),
        .instr_out(instrD),
        .PC_out(PCD),
        .PCPlus4_out(PCPlus4D)
    );
    
    control_unit cu(
        .op(opD),
        .funct3(funct3D),
        .funct7(funct7),
        .immSrc(immSrc),
        .ALUSrc(ALUSrcD),
        .ALUControl(ALUControlD),
        .ALU32(ALU32D),
        .jal(jalD),
        .jalr(jalrD),
        .branch(branchD),
        .memWrite(memWriteD),
        .memType(memTypeD),
        .resultSrc(resultSrcD),
        .regWrite(regWriteD),
        .ecall(ecallD),
        .csrrs(csrrsD)
    );
    
    register_file reg_file(
        .clk(clk),
        .reset(reset),
        .we(regWriteW),
        .csrrs(csrrsD),
        .bubble(PCPlus4W == `DataZero), // PCPlus4W is 0 only when there is a bubble
        .opcode(opW),
        .branchOp(branchOp), // increment mhpmcounter3 only when instruction is jal, jalr, or branch
        .validPrediction(PCSrc), // increment mhpmcounter4 only when instruction is jal, jalr, or branch and was predicted correctly
        .readRegister1(readRegister1D),
        .readRegister2(readRegister2D),
        .readCSR(readCSR),
        .writeRegister(writeRegW),
        .writeData(writeDataReg),
        .readData1(readData1D),
        .readData2(readData2D)
    );
    
    imm_generator imm_gen(
        .instr(instrD),
        .immSrc(immSrc),
        .immExt(immExtD)
    );
    
    ID_EX id_ex_reg(
        .clk(clk),
        .reset(reset | flushE), // flushing for load and control hazard
        .funct3_in(funct3D),
        .ALUSrc_in(ALUSrcD),
        .ALUControl_in(ALUControlD),
        .ALU32_in(ALU32D),
        .jal_in(jalD),
        .jalr_in(jalrD),
        .branch_in(branchD),
        .memWrite_in(memWriteD),
        .memType_in(memTypeD),
        .resultSrc_in(resultSrcD),
        .regWrite_in(regWriteD),
        .ecall_in(ecallD),
        .csrrs_in(csrrsD),
        .op_in(opD),
        .readData1_in(readData1D),
        .readData2_in(readData2D),
        .funct3_out(funct3E),
        .PC_in(PCD),
        .readRegister1_in(readRegister1D),
        .readRegister2_in(readRegister2D),
        .writeReg_in(writeRegD),
        .immExt_in(immExtD),
        .PCPlus4_in(PCPlus4D),
        .ALUSrc_out(ALUSrcE),
        .ALUControl_out(ALUControlE),
        .ALU32_out(ALU32E),
        .jal_out(jalE),
        .jalr_out(jalrE),
        .branch_out(branchE),
        .memWrite_out(memWriteE),
        .memType_out(memTypeE),
        .resultSrc_out(resultSrcE),
        .regWrite_out(regWriteE),
        .ecall_out(ecallE),
        .csrrs_out(csrrsE),
        .op_out(opE),
        .readData1_out(readData1E),
        .readData2_out(readData2E),
        .PC_out(PCE),
        .readRegister1_out(readRegister1E),
        .readRegister2_out(readRegister2E),
        .writeReg_out(writeRegE),
        .immExt_out(immExtE),
        .PCPlus4_out(PCPlus4E)
    );
    
    alu alu(
        .ALU32(ALU32E),
        .ALUControl(ALUControlE),
        .A(srcA),
        .B(srcB),
        .out(ALUResultE),
        .zero(zero),
        .lt(lt),
        .ltu(ltu)
    );
    
    branch_unit bu(
        .jal(jalE),
        .jalr(jalrE),
        .branch(branchE),
        .funct3(funct3E),
        .zero(zero),
        .lt(lt),
        .ltu(ltu),
        .ALUResult(ALUResultE),
        .PCPlus4(PCPlus4E),
        .PC(PCE),
        .immExt(immExtE),
        .PCPlusImm(PCPlusImmE),
        .PCNext(PCNextE),
        .branchOp(branchOp),
        .taken(taken)
    );
    
    EX_MEM ex_mem_reg(
        .clk(clk),
        .reset(reset),
        .memWrite_in(memWriteE),
        .memType_in(memTypeE),
        .resultSrc_in(resultSrcE),
        .regWrite_in(regWriteE),
        .ecall_in(ecallE),
        .op_in(opE),
        .ALUResult_in(ALUResultE),
        .writeData_in(writeDataE),
        .PCPlusImm_in(PCPlusImmE),
        .writeReg_in(writeRegE),
        .immExt_in(immExtE),
        .PCPlus4_in(PCPlus4E),
        .memWrite_out(memWriteM),
        .memType_out(memTypeM),
        .resultSrc_out(resultSrcM),
        .regWrite_out(regWriteM),
        .ecall_out(ecallM),
        .op_out(opM),
        .ALUResult_out(ALUResultM),
        .writeData_out(writeDataM),
        .PCPlusImm_out(PCPlusImmM),
        .writeReg_out(writeRegM),
        .immExt_out(immExtM),
        .PCPlus4_out(PCPlus4M)
    );
    
    MEM_WB mem_wb_reg(
        .clk(clk),
        .reset(reset),
        .resultSrc_in(resultSrcM),
        .regWrite_in(regWriteM),
        .ecall_in(ecallM),
        .op_in(opM),
        .ALUResult_in(ALUResultM),
        .readData_in(readDataM),
        .PCPlusImm_in(PCPlusImmM),
        .writeReg_in(writeRegM),
        .immExt_in(immExtM),
        .PCPlus4_in(PCPlus4M),
        .resultSrc_out(resultSrcW),
        .regWrite_out(regWriteW),
        .ecall_out(ecallW),
        .op_out(opW),
        .ALUResult_out(ALUResultW),
        .readData_out(readDataW),
        .PCPlusImm_out(PCPlusImmW),
        .writeReg_out(writeRegW),
        .immExt_out(immExtW),
        .PCPlus4_out(PCPlus4W)
    );
    
    hazard_unit hu(
        .opD(opD),
        .readRegister1D(readRegister1D),
        .readRegister1E(readRegister1E),
        .readRegister2D(readRegister2D), 
        .readRegister2E(readRegister2E),
        .writeRegE(writeRegE),
        .writeRegM(writeRegM),
        .writeRegW(writeRegW),
        .resultSrcE(resultSrcE),
        .PCD(PCD),
        .PCNextE(PCNextE),
        .bubble(PCPlus4E == `DataZero), // PCPlus4E is 0 only when there is a bubble
        .regWriteM(regWriteM),
        .regWriteW(regWriteW),
        .csrrs(csrrsE),
        .PCSrc(PCSrc),
        .stallF(stallF),
        .stallD(stallD),
        .flushD(flushD),
        .flushE(flushE),
        .forwardAE(forwardAE), 
        .forwardBE(forwardBE)
    );
    
endmodule
