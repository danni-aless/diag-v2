`timescale 1ns / 1ps
`include "diagv2_const.vh"

module IF_ID(
    input clk,
    input reset,
    input we,
    input [`InstrBusBits-1:0] instr_in,
    input [`DataBusBits-1:0] PC_in,
    input [`DataBusBits-1:0] PCPlus4_in,
    output reg [`InstrBusBits-1:0] instr_out,
    output reg [`DataBusBits-1:0] PC_out,
    output reg [`DataBusBits-1:0] PCPlus4_out
    );
    
    always @(posedge clk) begin
        if(reset) begin
            instr_out <= `DataZero32;
            PC_out <= `DataZero;
            PCPlus4_out <= `DataZero;
        end
        else if(we) begin
            instr_out <= instr_in;
            PC_out <= PC_in;
            PCPlus4_out <= PCPlus4_in;
        end
    end
    
endmodule
