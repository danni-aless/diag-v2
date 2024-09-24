`timescale 1ns / 1ps
`include "diagv2_const.vh"

module hazard_unit(
        input [`OpBusBits-1:0] opD,
        input [`RegAddrBits-1:0] readRegister1D, readRegister1E,
        input [`RegAddrBits-1:0] readRegister2D, readRegister2E,
        input [`RegAddrBits-1:0] writeRegE, writeRegM, writeRegW,
        input [`RsltSrcBusBits-1:0] resultSrcE,
        input [`DataBusBits-1:0] PCD, PCNextE,
        input bubble,
        input regWriteE, regWriteM, regWriteW,
        input csrrs,
        output PCSrc,
        output stallF, stallD,
        output flushD, flushE,
        output reg [`ForwardBusBits-1:0] forwardAE, forwardBE
    );
    
    wire validPrediction;
    reg reg1Used, reg2Used, loadStall, stall;
    
    // prediction control
    assign validPrediction = (PCD==PCNextE) | bubble;
    assign PCSrc = validPrediction;
    
    // stalling for load hazard
    assign stallF = stall & validPrediction; // validPrediction is necessary for no forwarding
    assign stallD = stall & validPrediction; // validPrediction is necessary for no forwarding
    
    // flushing for load and control hazard
    assign flushD = ~validPrediction;
    assign flushE = stall | ~validPrediction;
    
    // forwarding for data hazard
    always @(*) begin
        if(readRegister1E==writeRegM & regWriteM & readRegister1E!=`RegZero)
            forwardAE = 2'b10;
        else if(readRegister1E==writeRegW & regWriteW & readRegister1E!=`RegZero)
            forwardAE = 2'b01;
        else
            forwardAE = 2'b00;
        if(readRegister2E==writeRegM & regWriteM & readRegister2E!=`RegZero & ~csrrs)
            forwardBE = 2'b10;
        else if(readRegister2E==writeRegW & regWriteW & readRegister2E!=`RegZero & ~csrrs)
            forwardBE = 2'b01;
        else
            forwardBE = 2'b00;
    end
    
    always @(*) begin
        reg1Used = opD==`JALR | opD==`BRANCH | opD==`LOAD | opD==`STORE | opD==`OP_IMM | opD==`OP | opD==`OP_IMM_32 | opD==`OP_32;
        reg2Used = opD==`BRANCH | opD==`STORE | opD==`OP | opD==`OP_32;
        loadStall = (resultSrcE===`RsltSrcLOAD) & ((readRegister1D==writeRegE & readRegister1D!=`RegZero & reg1Used) 
                                                | (readRegister2D==writeRegE & readRegister2D!=`RegZero & reg2Used));
        stall = loadStall;
    end
    
    // NO FORWADING
/*   always @(*) begin
        reg1Used = opD==`JALR | opD==`BRANCH | opD==`LOAD | opD==`STORE | opD==`OP_IMM | opD==`OP | opD==`OP_IMM_32 | opD==`OP_32;
        reg2Used = opD==`BRANCH | opD==`STORE | opD==`OP | opD==`OP_32;
        stall = (reg1Used & readRegister1D==writeRegE & regWriteE & readRegister1D!=`RegZero)
              | (reg1Used & readRegister1D==writeRegM & regWriteM & readRegister1D!=`RegZero)
              | (reg2Used & readRegister2D==writeRegE & regWriteE & readRegister2D!=`RegZero & ~csrrs)
              | (reg2Used & readRegister2D==writeRegM & regWriteM & readRegister2D!=`RegZero & ~csrrs);
    end */
    
endmodule
