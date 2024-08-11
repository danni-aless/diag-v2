`timescale 1ns / 1ps
`include "diagv2_const.vh"

module alu(
        input ALU32,
        input [`AluCntrBusBits-1:0] ALUControl,
        input signed [`DataBusBits-1:0] A,
        input signed [`DataBusBits-1:0] B,
        output reg [`DataBusBits-1:0] out,
        output zero, lt, ltu // ALU signals
    );
    wire [`ShamtBusBits-1:0] shamt; // shift amount
    
    // for 32-bit operations
    wire signed [31:0] A_32, B_32;
    wire [`Shamt32BusBits-1:0] shamt_32; // shift amount
    reg [31:0] out_32;
    
    assign shamt = B[5:0];
    assign A_32 = A[31:0];
    assign B_32 = B[31:0];
    assign shamt_32 = B[4:0];
    assign zero = out ? 1'b0 : 1'b1;
    assign lt = A < B; // A and B are signed by default
    assign ltu = $unsigned(A) < $unsigned(B); // need to convert A and B to unsigned values
    
    always @(*) begin
        if(~ALU32)
            case(ALUControl)
                `ALUAdd:    out = A + B;
                `ALUSub:    out = A - B;
                `ALUSll:    out = A << shamt;
                `ALUSlt:    out = lt;
                `ALUSltu:   out = ltu;
                `ALUXor:    out = A ^ B;
                `ALUSrl:    out = A >> shamt;
                `ALUSra:    out = A >>> shamt;
                `ALUOr:     out = A | B;
                `ALUAnd:    out = A & B;
                default:    out = `DataZero;
            endcase
        else begin
            case(ALUControl)
                `ALUAdd:    out_32 = A_32 + B_32;
                `ALUSub:    out_32 = A_32 - B_32;
                `ALUSll:    out_32 = A_32 << shamt_32;
                `ALUSrl:    out_32 = A_32 >> shamt_32;
                `ALUSra:    out_32 = A_32 >>> shamt_32;
                default:    out_32 = `DataZero32;
            endcase
            out = {{32{out_32[31]}}, out_32[31:0]};
        end
    end

endmodule
