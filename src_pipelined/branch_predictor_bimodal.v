`timescale 1ns / 1ps
`include "diagv2_const.vh"

module branch_predictor_bimodal(
    input clk,
    input reset,
    input we, // when instruction is jal, jalr, or branch
    input [`DataBusBits-1:0] PC, PCUpdate, targetUpdate,
    input takenUpdate, // 1 -> taken, 0 -> not taken
    output [`DataBusBits-1:0] PCPlus4,
    output [`DataBusBits-1:0] PCPrediction
    );
    
//  PC ADDRESS:
//      63  -  12|11   -    2|1  -  0
//         TAG   | BTB INDEX | ZEROS
//       52 bits |  10 bits  | 2 bits
    
//  BTB LINE:
//      115  -  64|63      -      0
//          TAG   | TARGET ADDRESS
//       52 bits  |    64 bits
    
    reg [1:0] BHT[0:1023]; // branch history table (2-bit saturation counters)
    reg [115:0] BTB[0:1023]; // branch target buffer (direct-mapped cache)
    
    wire [51:0] PCTag = PC[63:12];
    wire [9:0] BTBIndex = PC[11:2];
    wire [51:0] BTBTag = BTB[BTBIndex][115:64];
    wire takenPrediction = BHT[BTBIndex][1];
    wire [63:0] target = BTB[BTBIndex][63:0];
    
    wire [51:0] PCTagUpdate = PCUpdate[63:12];
    wire [9:0] BTBIndexUpdate = PCUpdate[11:2];
    
    assign PCPrediction = (PCTag==BTBTag & takenPrediction) ? target : PCPlus4;
    
    integer i;
    
    always @(negedge clk) begin
        if(reset) begin
            for(i=0; i<1024; i=i+1) begin
                BTB[i] <= 116'b0;
                BHT[i] <= 2'b0;
            end
        end
        else if(we) begin
            if(takenUpdate)
                BTB[BTBIndexUpdate] <= {PCTagUpdate, targetUpdate}; // BTB line update
            case(BHT[BTBIndexUpdate]) // 2-bit saturation counter update
                2'b00: // strongly not taken
                    BHT[BTBIndexUpdate] <= takenUpdate ? 2'b01 : 2'b00;
                2'b01: // weakly not taken
                    BHT[BTBIndexUpdate] <= takenUpdate ? 2'b10 : 2'b00;
                2'b10: // weakly taken
                    BHT[BTBIndexUpdate] <= takenUpdate ? 2'b11 : 2'b01;
                2'b11: // strongly taken
                    BHT[BTBIndexUpdate] <= takenUpdate ? 2'b11 : 2'b10;
            endcase
        end
    end
    
    adder pc_adder(
        .in_1(PC),
        .in_2(`DataBusBits'd4),
        .out(PCPlus4)
    );
    
endmodule
