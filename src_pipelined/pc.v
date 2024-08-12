`timescale 1ns / 1ps
`include "diagv2_const.vh"

module pc(
    input clk,
    input reset,
    input we,
    input [`DataBusBits-1:0] PCNext,
    output reg [`DataBusBits-1:0] PC
    );
    
    always @(posedge clk) begin
        if(reset)
            PC <= `DataZero;
        else if(we)
            PC <= PCNext;
    end

endmodule
