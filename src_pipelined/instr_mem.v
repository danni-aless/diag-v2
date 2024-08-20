`timescale 1ns / 1ps
`include "diagv2_const.vh"

module instr_mem(
        input [`DataBusBits-1:0] addr,
        output [`InstrBusBits-1:0] instr
    );
    
    reg [`InstrBusBits-1:0] imem[0:4095]; // maximum of 4096 32-bit instructions
    
    assign instr = imem[addr[`DataBusBits-1:2]]; // word-aligned
    
    /*initial begin
        $readmemh("add.mem", imem); // write machine code to instruction memory
    end*/
    
endmodule
