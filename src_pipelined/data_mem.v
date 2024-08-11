`timescale 1ns / 1ps
`include "diagv2_const.vh"

module data_mem(
        input clk,
        input we,
        input [`MemTypeBusBits-1:0] memType,
        input [`DataBusBits-1:0] addr,
        input [`DataBusBits-1:0] wd,
        output reg [`DataBusBits-1:0] rd
    );
    
    reg [`DataBusBits-1:0] dmem[0:255]; // RAM consists of 256 64-bit lines
    
    always @(*) begin
        // TODO: misaligned access
        case(memType)
            `MemTypeB:
                case(addr[2:0])
                    3'd0:   rd = {{56{dmem[addr>>3][7]}}, dmem[addr>>3][7:0]};
                    3'd1:   rd = {{56{dmem[addr>>3][15]}}, dmem[addr>>3][15:8]};
                    3'd2:   rd = {{56{dmem[addr>>3][23]}}, dmem[addr>>3][23:16]};
                    3'd3:   rd = {{56{dmem[addr>>3][31]}}, dmem[addr>>3][31:24]};
                    3'd4:   rd = {{56{dmem[addr>>3][39]}}, dmem[addr>>3][39:32]};
                    3'd5:   rd = {{56{dmem[addr>>3][47]}}, dmem[addr>>3][47:40]};
                    3'd6:   rd = {{56{dmem[addr>>3][55]}}, dmem[addr>>3][55:48]};
                    3'd7:   rd = {{56{dmem[addr>>3][63]}}, dmem[addr>>3][63:56]};
                endcase
            `MemTypeH:
                case(addr[2:1])
                    2'd0:   rd = {{48{dmem[addr>>3][15]}}, dmem[addr>>3][15:0]};
                    2'd1:   rd = {{48{dmem[addr>>3][31]}}, dmem[addr>>3][31:16]};
                    2'd2:   rd = {{48{dmem[addr>>3][47]}}, dmem[addr>>3][47:32]};
                    2'd3:   rd = {{48{dmem[addr>>3][63]}}, dmem[addr>>3][63:48]};
                endcase
            `MemTypeW:
                case(addr[2])
                    1'd0:   rd = {{32{dmem[addr>>3][31]}}, dmem[addr>>3][31:0]};
                    1'd1:   rd = {{32{dmem[addr>>3][63]}}, dmem[addr>>3][63:32]};
                endcase
            `MemTypeD:      rd = dmem[addr>>3];
            `MemTypeBU:
                case(addr[2:0])
                    3'd0:   rd = {{56{1'b0}}, dmem[addr>>3][7:0]};
                    3'd1:   rd = {{56{1'b0}}, dmem[addr>>3][15:8]};
                    3'd2:   rd = {{56{1'b0}}, dmem[addr>>3][23:16]};
                    3'd3:   rd = {{56{1'b0}}, dmem[addr>>3][31:24]};
                    3'd4:   rd = {{56{1'b0}}, dmem[addr>>3][39:32]};
                    3'd5:   rd = {{56{1'b0}}, dmem[addr>>3][47:40]};
                    3'd6:   rd = {{56{1'b0}}, dmem[addr>>3][55:48]};
                    3'd7:   rd = {{56{1'b0}}, dmem[addr>>3][63:56]};
                endcase
            `MemTypeHU:
                case(addr[2:1])
                    2'd0:   rd = {{48{1'b0}}, dmem[addr>>3][15:0]};
                    2'd1:   rd = {{48{1'b0}}, dmem[addr>>3][31:16]};
                    2'd2:   rd = {{48{1'b0}}, dmem[addr>>3][47:32]};
                    2'd3:   rd = {{48{1'b0}}, dmem[addr>>3][63:48]};
                endcase
            `MemTypeWU:
                case(addr[2])
                    1'd0:   rd = {{32{1'b0}}, dmem[addr>>3][31:0]};
                    1'd1:   rd = {{32{1'b0}}, dmem[addr>>3][63:32]};
                endcase
            default: rd = `DataZero;
        endcase
    end
    
    always @(posedge clk) begin
        if(we) begin
            // TODO: misaligned access
            case(memType)
                `MemTypeB:
                    case(addr[2:0])
                        3'd0:   dmem[addr>>3][7:0] <= wd[7:0];
                        3'd1:   dmem[addr>>3][15:8] <= wd[7:0];
                        3'd2:   dmem[addr>>3][23:16] <= wd[7:0];
                        3'd3:   dmem[addr>>3][31:24] <= wd[7:0];
                        3'd4:   dmem[addr>>3][39:32] <= wd[7:0];
                        3'd5:   dmem[addr>>3][47:40] <= wd[7:0];
                        3'd6:   dmem[addr>>3][55:48] <= wd[7:0];
                        3'd7:   dmem[addr>>3][63:56] <= wd[7:0];
                    endcase
                `MemTypeH:
                    case(addr[2:1])
                        2'd0:   dmem[addr>>3][15:0] <= wd[15:0];
                        2'd1:   dmem[addr>>3][31:16] <= wd[15:0];
                        2'd2:   dmem[addr>>3][47:32] <= wd[15:0];
                        2'd3:   dmem[addr>>3][63:48] <= wd[15:0];
                    endcase
                `MemTypeW:
                    case(addr[2])
                        1'd0:   dmem[addr>>3][31:0] <= wd[31:0];
                        1'd1:   dmem[addr>>3][63:32] <= wd[31:0];
                    endcase
                `MemTypeD:      dmem[addr>>3] <= wd;
                default: ;
            endcase
        end
    end
    
    initial begin
        $readmemh("ram.mem", dmem);
    end
    
endmodule
