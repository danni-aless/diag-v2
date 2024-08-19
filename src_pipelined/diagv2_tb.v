`timescale 1ns / 1ps
`include "diagv2_const.vh"

module diagv2_tb();

    reg CLK, RESET, HALT;
    wire ecall;
    wire [`DataBusBits-1:0] statusCode; // x10 register

    diagv2_top top(
        .clk(CLK),
        .reset(RESET),
        .ecall(ecall),
        .statusCode(statusCode)
    );
	
    initial begin
        CLK <= 1'b0;
        RESET <= 1'b1;
        HALT <= 1'b0;
        #20;
        RESET <= 1'b0;
    end
    
    always begin // this block repeats forever
        #10 CLK <= ~(CLK ^ HALT); // HALT==0 -> CLK <= ~CLK, HALT==1 -> CLK <= CLK
    end
    
    always @(negedge CLK) begin
        if(ecall) begin
            $display("diagv2_tb - ECALL Status code: %2d", statusCode);
            HALT <= 1'b1;
        end
    end

endmodule
