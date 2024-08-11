`timescale 1ns / 1ps

module diagv2_tb();

    reg CLK, RESET;

	diagv2_top top(
	   .clk(CLK),
	   .reset(RESET)
	);
	
	initial begin
	    CLK <= 0;
		RESET <= 1;
		#20;
		RESET <= 0;
	end
	
	always //this block repeat forever
    begin
        #10 CLK <= ~CLK;
    end

endmodule
