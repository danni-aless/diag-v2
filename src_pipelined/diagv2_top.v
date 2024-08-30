`timescale 1ns / 1ps
`include "diagv2_const.vh"

module diagv2_top(
    input clk,
    input reset,
    output ecall // signal for testing/debugging
    );

    wire [`InstrBusBits-1:0] instruction;
    wire [`DataBusBits-1:0] readData;
    wire [`DataBusBits-1:0] PC;
    wire [`DataBusBits-1:0] DataAddr;
    wire [`DataBusBits-1:0] writeData;
    wire memWrite;
    wire [`MemTypeBusBits-1:0] memType;
    
    diagv2_core core(
        .clk(clk),
        .reset(reset),
        .instrF(instruction),
        .readDataM(readData),
        .PCF(PC),
        .ALUResultM(DataAddr),
        .writeDataM(writeData),
        .memWriteM(memWrite),
        .memTypeM(memType),
        .ecallW(ecall)
    );
    
    instr_mem imem(
        .addr(PC),
        .instr(instruction)
    );
    
    data_mem dmem(
        .clk(clk),
        .we(memWrite),
        .memType(memType),
        .addr(DataAddr),
        .wd(writeData),
        .rd(readData)
    );
    
endmodule
