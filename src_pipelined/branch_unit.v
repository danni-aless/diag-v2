`timescale 1ns / 1ps
`include "diagv2_const.vh"

module branch_unit(
        input jal, jalr, branch,
        input [`Funct3BusBits-1:0] funct3, // for branch type
        input zero, lt, ltu, // ALU signals
        input [`DataBusBits-1:0] ALUResult, PCPlus4,
        input [`DataBusBits-1:0] PC, immExt,
        output [`DataBusBits-1:0] PCPlusImm,
        output [`DataBusBits-1:0] PCNext
    );
    
    reg branchTaken;
    wire [`PCNextSrcBusBits-1:0] PCNextSrc;
    
    assign PCNextSrc[0] = jal | jalr | (branch & branchTaken);
    assign PCNextSrc[1] = jalr;
    assign PCNext = PCNextSrc[1] ? ALUResult : (PCNextSrc[0] ? PCPlusImm : PCPlus4);
    
    always @(*) begin
        case(funct3)
            `Funct3BEQ:     branchTaken = zero;
            `Funct3BNE:     branchTaken = ~zero;
            `Funct3BLT:     branchTaken = lt;
            `Funct3BGE:     branchTaken = ~lt;
            `Funct3BLTU:    branchTaken = ltu;
            `Funct3BGEU:    branchTaken = ~ltu;
            default:        branchTaken = 1'b0;
        endcase
    end
    
    adder branch_adder(
        .in_1(PC),
        .in_2(immExt),
        .out(PCPlusImm)
    );
    
endmodule
