`timescale 1ns / 1ps
`include "diagv2_const.vh"

module control_unit(
        input [`OpBusBits-1:0] op,
        input [`Funct3BusBits-1:0] funct3,
        input [`Funct7BusBits-1:0] funct7,
        output [`ImmSrcBusBits-1:0] immSrc,
        output ALUSrc, ALU32, jal, jalr, branch,
        output reg [`AluCntrBusBits-1:0] ALUControl,
        output memWrite,
        output [`MemTypeBusBits-1:0] memType,
        output [`RsltSrcBusBits-1:0] resultSrc,
        output regWrite
    );
    
    reg [11:0] signals; // signals reg for better assignment
    
    assign {regWrite, immSrc, ALUSrc, memWrite, resultSrc, branch, jal, jalr} = signals;
    assign ALU32 = (op == `OP_IMM_32) | (op == `OP_32);
    assign memType = funct3;
    
    always @(*) begin
        case(op) // for signals reg
            `LUI:
                signals = {1'b1, `ImmSrcUType, 1'bx, 1'b0, 3'b011, 1'b0, 1'b0, 1'b0};
            `AUIPC:
                signals = {1'b1, `ImmSrcUType, 1'bx, 1'b0, 3'b100, 1'b0, 1'b0, 1'b0};
            `JAL:
                signals = {1'b1, `ImmSrcJType, 1'bx, 1'b0, 3'b010, 1'b0, 1'b1, 1'b0};
            `JALR:
                signals = {1'b1, `ImmSrcIType, 1'b1, 1'b0, 3'b010, 1'b0, 1'b0, 1'b1};
            `BRANCH:
                signals = {1'b0, `ImmSrcBType, 1'b0, 1'b0, 3'bxxx, 1'b1, 1'b0, 1'b0};
            `LOAD:
                signals = {1'b1, `ImmSrcIType, 1'b1, 1'b0, 3'b001, 1'b0, 1'b0, 1'b0};
            `STORE:
                signals = {1'b0, `ImmSrcSType, 1'b1, 1'b1, 3'bxxx, 1'b0, 1'b0, 1'b0};
            `OP_IMM, `OP_IMM_32:
                signals = {1'b1, `ImmSrcIType, 1'b1, 1'b0, 3'b000, 1'b0, 1'b0, 1'b0};
            `OP, `OP_32:
                signals = {1'b1, `ImmSrcRType, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 1'b0};
            default:
                signals = {1'b0, `ImmSrcRType, 1'bx, 1'b0, 3'bxxx, 1'b0, 1'b0, 1'b0};
        endcase
        case(op) // for ALUControl
            `JALR:      ALUControl = `ALUAdd;
            `BRANCH:    ALUControl = `ALUSub; // only BEQ and BNE need ALUSub
            `LOAD:      ALUControl = `ALUAdd;
            `STORE:     ALUControl = `ALUAdd;
            `OP_IMM, `OP_IMM_32:    
                        ALUControl = (funct3 == `Funct3SRxI) ? {funct7[5], funct3} : {1'b0, funct3};
            `OP, `OP_32:        
                        ALUControl = {funct7[5], funct3};
            default:    ALUControl = {`AluCntrBusBits{1'bx}};
        endcase
    end
   
endmodule
