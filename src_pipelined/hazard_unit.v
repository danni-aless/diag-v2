`timescale 1ns / 1ps
`include "diagv2_const.vh"

module hazard_unit(
        input [`OpBusBits-1:0] opD,
        input [`RegAddrBits-1:0] readRegister1D, readRegister1E,
        input [`RegAddrBits-1:0] readRegister2D, readRegister2E,
        input [`RegAddrBits-1:0] writeRegE, writeRegM, writeRegW,
        input [`RsltSrcBusBits-1:0] resultSrcE,
        input regWriteM, regWriteW,
        input branch,
        output stallF, stallD,
        output flushD, flushE,
        output reg [`ForwardBusBits-1:0] forwardAE, forwardBE
    );
    
    reg reg1Used, reg2Used, loadStall;
    
    // stalling for load hazard
    assign stallF = loadStall;
    assign stallD = loadStall;
    
    // flushing for load and control hazard
    assign flushD = branch;
    assign flushE = loadStall | branch;
    
    // forwarding for data hazard
    always @(*) begin
        if(readRegister1E==writeRegM & regWriteM & readRegister1E!=`RegZero)
            forwardAE = 2'b10;
        else if(readRegister1E==writeRegW & regWriteW & readRegister1E!=`RegZero)
            forwardAE = 2'b01;
        else
            forwardAE = 2'b00;
        if(readRegister2E==writeRegM & regWriteM & readRegister2E!=`RegZero)
            forwardBE = 2'b10;
        else if(readRegister2E==writeRegW & regWriteW & readRegister2E!=`RegZero)
            forwardBE = 2'b01;
        else
            forwardBE = 2'b00;
    end
    
    always @(*) begin
        reg1Used = opD!=`LUI & opD!=`AUIPC & opD!=`JAL;
        reg2Used = opD==`OP | opD==`OP_32 | opD==`STORE | opD==`BRANCH;
        loadStall = (resultSrcE==`RsltSrcLOAD) & ((readRegister1D==writeRegE & readRegister1D!=`RegZero & reg1Used) 
                                                | (readRegister2D==writeRegE & readRegister2D!=`RegZero & reg2Used));
    end
    
endmodule
