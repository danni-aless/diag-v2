`timescale 1ns / 1ps
`include "diagv2_const.vh"

module branch_unit(
        input [`Funct3BusBits-1:0] funct3, // for branch type
        input zero, lt, ltu, // ALU signals
        input [`DataBusBits-1:0] PC,
        input [`DataBusBits-1:0] immExt,
        output [`DataBusBits-1:0] PCTarget,
        output reg branchTaken
    );
    
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
        .out(PCTarget)
    );
    
endmodule
