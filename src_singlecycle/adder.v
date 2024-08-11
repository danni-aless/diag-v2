`timescale 1ns / 1ps
`include "diagv2_const.vh"

module adder( 
    input [`DataBusBits-1:0] in_1,
    input [`DataBusBits-1:0] in_2,
    output [`DataBusBits-1:0] out
    );
    
    assign out = in_1 + in_2;
    
endmodule
