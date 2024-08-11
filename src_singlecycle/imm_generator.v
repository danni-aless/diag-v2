`timescale 1ns / 1ps
`include "diagv2_const.vh"

module imm_generator(
    input [`InstrBusBits-1:0] instr,
    input [`ImmSrcBusBits-1:0] immSrc,
    output reg [`DataBusBits-1:0] immExt
    );
    
    always @(*) begin
        case(immSrc)
            `ImmSrcIType:
                immExt = {{52{instr[31]}}, instr[31:20]};
            `ImmSrcSType:
                immExt = {{52{instr[31]}}, instr[31:25], instr[11:7]};
            `ImmSrcBType:
                immExt = {{52{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            `ImmSrcUType:
                immExt = {{32{instr[31]}}, instr[31:12], {12{1'b0}}};
            `ImmSrcJType:
                immExt = {{44{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default:
                immExt = {`DataBusBits{1'bx}};
        endcase
    end
    
endmodule
