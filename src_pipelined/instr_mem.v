`timescale 1ns / 1ps
`include "diagv2_const.vh"

module instr_mem(
        input [`DataBusBits-1:0] addr,
        output [`InstrBusBits-1:0] instr
    );
    
    reg [`InstrBusBits-1:0] imem[0:255]; // maximum of 256 32-bit instructions
    
    assign instr = imem[addr[`DataBusBits-1:2]]; // word-aligned
    
    initial begin
        $readmemh("addi.mem", imem); // write machine code to instruction memory
    end
    
endmodule
