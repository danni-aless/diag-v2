`timescale 1ns / 1ps
`include "diagv2_const.vh"

module register_file(
        input clk,
        input reset,
        input we,
        input csrrs,
        input [`OpBusBits-1:0] opcode,
        input branchOp, validPrediction,
        input [`RegAddrBits-1:0] readRegister1,
        input [`RegAddrBits-1:0] readRegister2,
        input [`CSRAddrBits-1:0] readCSR,
        input [`RegAddrBits-1:0] writeRegister,
        input [`DataBusBits-1:0] writeData,
        output reg [`DataBusBits-1:0] readData1,
        output reg [`DataBusBits-1:0] readData2
    );
    
    reg [`DataBusBits-1:0] registers[0:31];
    reg [`DataBusBits-1:0] csr[0:4095]; // control and status registers
    
    integer i;
    
    always @(*) begin
        readData1 = registers[readRegister1];
        readData2 = csrrs ? csr[readCSR] : registers[readRegister2];
    end
    
    always @(negedge clk) begin
        if(reset) begin
            for(i=0; i<32; i=i+1) begin
                registers[i] <= `DataZero;
            end
            for(i=0; i<4096; i=i+1) begin
                csr[i] <= `DataZero;
            end
        end
        else begin
            if(we && (writeRegister != `RegZero)) // 0-reg must be 0 
                registers[writeRegister] <= writeData;
            if(opcode) begin 
                csr[`MINSTRET] <= csr[`MINSTRET]+1; // minstret should be incremented only when a valid instruction is present
                case(opcode)
                    `OP, `OP_32, `OP_IMM, `OP_IMM_32: // ALU instructions
                        csr[`MHPMCOUNTER3] <= csr[`MHPMCOUNTER3]+1;
                    `LOAD, `STORE: // memory instructions
                        csr[`MHPMCOUNTER4] <= csr[`MHPMCOUNTER4]+1;
                    `JAL, `JALR, `BRANCH: // branch instructions
                        csr[`MHPMCOUNTER5] <= csr[`MHPMCOUNTER5]+1;
                    default: ;
                endcase
            end
            if(branchOp & validPrediction)
                csr[`MHPMCOUNTER6] <= csr[`MHPMCOUNTER6]+1; // total number of correctly predicted branch instructions
            csr[`MCYCLE] <= csr[`MCYCLE]+1;
        end
    end
    
endmodule
