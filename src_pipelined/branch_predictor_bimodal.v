`timescale 1ns / 1ps
`include "diagv2_const.vh"

module branch_predictor_bimodal(
    input [`DataBusBits-1:0] PC,
    output [`DataBusBits-1:0] PCPlus4,
    output [`DataBusBits-1:0] PCPrediction
    );
    
    assign PCPrediction = PCPlus4;
    
    adder pc_adder(
        .in_1(PC),
        .in_2(`DataBusBits'd4),
        .out(PCPlus4)
    );
    
endmodule
