`timescale 1ns / 1ps
`include "diagv2_const.vh"

module branch_predictor_gshare(
    input clk,
    input reset,
    input we, // when instruction is jal, jalr, or branch
    input [`DataBusBits-1:0] PC, PCUpdate, targetUpdate,
    input takenUpdate, // 1 -> taken, 0 -> not taken
    output [`DataBusBits-1:0] PCPlus4,
    output [`DataBusBits-1:0] PCPrediction
    );
    
    parameter N = 14; // GHR and BTB index length
    
//  (N = 10)
//  PC ADDRESS:
//      63  -  12|11   -    2|1  -  0
//         TAG   | BTB INDEX | ZEROS
//       52 bits |  10 bits  | 2 bits
    
//  BTB LINE:
//         116   |115  -   64|63      -      0
//     VALID BIT |    TAG    | TARGET ADDRESS
//        1 bit  |  52 bits  |    64 bits
    
    reg [N-1:0] GHR; // global history register (N-bit shift register)
    reg [1:0] PHT[0:(1<<N)-1]; // pattern history table (2-bit saturation counters)
    reg [126-N:0] BTB[0:(1<<N)-1]; // branch target buffer (direct-mapped cache)
    
    wire [61-N:0] PCTag = PC[63:N+2];
    wire [N-1:0] BTBIndex = PC[N+1:2];
    wire [N-1:0] PHTIndex = PC[N+1:2] ^ GHR;
    wire validBit = BTB[BTBIndex][126-N];
    wire [61-N:0] BTBTag = BTB[BTBIndex][125-N:64];
    wire takenPrediction = PHT[PHTIndex][1]; // when counter is strongly or weakly taken
    wire [63:0] target = BTB[BTBIndex][63:0];
    
    wire [61-N:0] PCTagUpdate = PCUpdate[63:N+2];
    wire [N-1:0] BTBIndexUpdate = PCUpdate[N+1:2];
    wire [N-1:0] PHTIndexUpdate = PCUpdate[N+1:2] ^ GHR;
    
    assign PCPrediction = (validBit & PCTag==BTBTag & takenPrediction) ? target : PCPlus4;
    
    integer i;
    
    always @(negedge clk) begin
        if(reset) begin
            GHR <= {N{1'b0}};
            for(i=0; i<(1<<N); i=i+1) begin
                BTB[i] <= {127-N{1'b0}};
                PHT[i] <= 2'b11; // seems the best initialization
            end
        end
        else if(we) begin
            GHR <= {GHR[N-2:0], takenUpdate}; // GHR update (shift)
            if(takenUpdate)
                BTB[BTBIndexUpdate] <= {1'b1, PCTagUpdate, targetUpdate}; // BTB line update
            case(PHT[PHTIndexUpdate]) // 2-bit saturation counter update
                2'b00: // strongly not taken
                    PHT[PHTIndexUpdate] <= takenUpdate ? 2'b01 : 2'b00;
                2'b01: // weakly not taken
                    PHT[PHTIndexUpdate] <= takenUpdate ? 2'b10 : 2'b00;
                2'b10: // weakly taken
                    PHT[PHTIndexUpdate] <= takenUpdate ? 2'b11 : 2'b01;
                2'b11: // strongly taken
                    PHT[PHTIndexUpdate] <= takenUpdate ? 2'b11 : 2'b10;
            endcase
        end
    end
    
    adder pc_adder(
        .in_1(PC),
        .in_2(`DataBusBits'd4),
        .out(PCPlus4)
    );
    
endmodule
