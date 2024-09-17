`timescale 1ns / 1ps
`include "diagv2_const.vh"

module register_file(
        input clk,
        input reset,
        input we,
        input [`RegAddrBits-1:0] readRegister1,
        input [`RegAddrBits-1:0] readRegister2,
        input [`RegAddrBits-1:0] writeRegister,
        input [`DataBusBits-1:0] writeData,
        output reg [`DataBusBits-1:0] readData1,
        output reg [`DataBusBits-1:0] readData2
    );
    
    reg [`DataBusBits-1:0] registers[0:31];
    integer i;
    
    always @(*) begin
        readData1 = registers[readRegister1];
        readData2 = registers[readRegister2];
    end
    
    always @(posedge clk) begin
        if(reset) begin
            for(i=0; i<32; i=i+1) begin
                registers[i] <= `DataZero;
            end
        end
        else if(we && (writeRegister != `RegZero)) begin // 0-reg must be 0 
            registers[writeRegister] <= writeData;
        end
    end
    
endmodule
