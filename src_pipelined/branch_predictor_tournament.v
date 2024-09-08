`timescale 1ns / 1ps
`include "diagv2_const.vh"

module branch_predictor_tournament(
    input clk,
    input reset,
    input we, // when instruction is jal, jalr, or branch
    input [`DataBusBits-1:0] PC, PCUpdate, targetUpdate,
    input takenUpdate, // 1 -> taken, 0 -> not taken
    output [`DataBusBits-1:0] PCPlus4,
    output [`DataBusBits-1:0] PCPrediction
    );
    
    parameter N = 13; // GHR and BTB index length
    
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
    reg [1:0] selector[0:(1<<N)-1]; // chooses the predictor (2-bit saturation counters)
    reg [1:0] PHT1[0:(1<<N)-1]; // pattern history table 1 (2-bit saturation counters)
    reg [1:0] PHT2[0:(1<<N)-1]; // pattern history table 2 (2-bit saturation counters)
    reg [126-N:0] BTB[0:(1<<N)-1]; // branch target buffer (direct-mapped cache)
    
    wire [61-N:0] PCTag = PC[63:N+2];
    
    wire [N-1:0] BTBIndex = PC[N+1:2];
    wire validBit = BTB[BTBIndex][126-N];
    wire [61-N:0] BTBTag = BTB[BTBIndex][125-N:64];
    wire [63:0] target = BTB[BTBIndex][63:0];
    
    wire [N-1:0] selectorIndex = PC[N+1:2];
    wire predictorChoice = selector[selectorIndex][1];
    
    wire [N-1:0] PHT1Index = PC[N+1:2]; // for bimodal predictor
    wire [N-1:0] PHT2Index = PC[N+1:2] ^ GHR; // for gshare predictor
    wire takenPrediction = predictorChoice ? PHT1[PHT1Index][1] : PHT2[PHT2Index][1];
    
    wire [61-N:0] PCTagUpdate = PCUpdate[63:N+2];
    wire [N-1:0] BTBIndexUpdate = PCUpdate[N+1:2];
    wire [N-1:0] selectorIndexUpdate = PCUpdate[N+1:2];
    wire [N-1:0] PHT1IndexUpdate = PCUpdate[N+1:2]; // for bimodal predictor
    wire [N-1:0] PHT2IndexUpdate = PCUpdate[N+1:2] ^ GHR; // for gshare predictor
    
    wire P1c = ~(PHT1[PHT1IndexUpdate][1] ^ takenUpdate); // first predictor is correct => P1c=1, else P1c=0
    wire P2c = ~(PHT2[PHT2IndexUpdate][1] ^ takenUpdate); // second predictor is correct => P2c=1, else P2c=0
    wire increment = P1c & ~P2c; // increment selector if first predictor is correct and second isn't
    wire decrement = ~P1c & P2c; // decrement selector if second predictor is correct and first isn't
    
    assign PCPrediction = (validBit & PCTag==BTBTag & takenPrediction) ? target : PCPlus4;
    
    integer i;
    
    always @(negedge clk) begin
        if(reset) begin
            GHR <= {N{1'b0}};
            for(i=0; i<(1<<N); i=i+1) begin
                BTB[i] <= {127-N{1'b0}};
                selector[i] <= 2'b10; // seems the best initialization
                PHT1[i] <= 2'b10; // seems the best initialization
                PHT2[i] <= 2'b10; // seems the best initialization
            end
        end
        else if(we) begin
            GHR <= {GHR[N-2:0], takenUpdate}; // GHR update (shift)
            if(takenUpdate)
                BTB[BTBIndexUpdate] <= {1'b1, PCTagUpdate, targetUpdate}; // BTB line update
            case(selector[selectorIndexUpdate]) // selector 2-bit saturation counter update
                2'b00: // strongly second predictor
                    selector[selectorIndexUpdate] <= increment ? 2'b01 : 
                                                     decrement ? 2'b00 : 2'b00;
                2'b01: // weakly second predictor
                    selector[selectorIndexUpdate] <= increment ? 2'b10 : 
                                                     decrement ? 2'b00 : 2'b01;
                2'b10: // weakly first predictor
                    selector[selectorIndexUpdate] <= increment ? 2'b11 : 
                                                     decrement ? 2'b01 : 2'b10;
                2'b11: // strongly first predictor
                    selector[selectorIndexUpdate] <= increment ? 2'b11 : 
                                                     decrement ? 2'b10 : 2'b11;
            endcase
            case(PHT1[PHT1IndexUpdate]) // first predictor 2-bit saturation counter update
                2'b00: // strongly not taken
                    PHT1[PHT1IndexUpdate] <= takenUpdate ? 2'b01 : 2'b00;
                2'b01: // weakly not taken
                    PHT1[PHT1IndexUpdate] <= takenUpdate ? 2'b10 : 2'b00;
                2'b10: // weakly taken
                    PHT1[PHT1IndexUpdate] <= takenUpdate ? 2'b11 : 2'b01;
                2'b11: // strongly taken
                    PHT1[PHT1IndexUpdate] <= takenUpdate ? 2'b11 : 2'b10;
            endcase
            case(PHT2[PHT2IndexUpdate]) // second predictor 2-bit saturation counter update
                2'b00: // strongly not taken
                    PHT2[PHT2IndexUpdate] <= takenUpdate ? 2'b01 : 2'b00;
                2'b01: // weakly not taken
                    PHT2[PHT2IndexUpdate] <= takenUpdate ? 2'b10 : 2'b00;
                2'b10: // weakly taken
                    PHT2[PHT2IndexUpdate] <= takenUpdate ? 2'b11 : 2'b01;
                2'b11: // strongly taken
                    PHT2[PHT2IndexUpdate] <= takenUpdate ? 2'b11 : 2'b10;
            endcase
        end
    end
    
    adder pc_adder(
        .in_1(PC),
        .in_2(`DataBusBits'd4),
        .out(PCPlus4)
    );
      
endmodule
