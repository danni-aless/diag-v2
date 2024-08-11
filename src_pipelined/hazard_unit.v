`timescale 1ns / 1ps
`include "diagv2_const.vh"

module hazard_unit(
        input [`RegAddrBits-1:0] readRegister1E, readRegister2E,
        input [`RegAddrBits-1:0] writeRegM, writeRegW,
        input regWriteM, regWriteW,
        output reg [`ForwardBusBits-1:0] forwardAE, forwardBE
    );
    
    // forwarding
    always @(*) begin
        if(readRegister1E==writeRegM & regWriteM & readRegister1E!=0)
            forwardAE = 2'b10;
        else if(readRegister1E==writeRegW & regWriteW & readRegister1E!=0)
            forwardAE = 2'b01;
        else
            forwardAE = 2'b00;
        if(readRegister2E==writeRegM & regWriteM & readRegister2E!=0)
            forwardBE = 2'b10;
        else if(readRegister2E==writeRegW & regWriteW & readRegister2E!=0)
            forwardBE = 2'b01;
        else
            forwardBE = 2'b00;
    end
    
endmodule
