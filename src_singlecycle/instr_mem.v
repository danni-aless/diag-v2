`timescale 1ns / 1ps
`include "diagv2_const.vh"

module instr_mem(
        input [`DataBusBits-1:0] addr,
        output [`InstrBusBits-1:0] instr
    );
    
    parameter N = 14;
    
    reg [`InstrBusBits-1:0] imem[0:(1<<N)-1]; // maximum of 2^N 32-bit instructions
    
    assign instr = imem[addr[`DataBusBits-1:2]]; // word-aligned
    
    integer i;
    
    initial begin
        for(i=0; i<(1<<N); i=i+1) begin
            imem[i] <= `DataZero32;
        end
    end
    
endmodule
