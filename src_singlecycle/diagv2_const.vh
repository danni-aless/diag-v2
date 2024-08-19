`ifndef _Const
`define _Const

`define DataBusBits     64
`define InstrBusBits    32
`define RegAddrBits	 5

`define DataZero    64'b0
`define DataZero32  32'b0
`define RegZero	     5'b0

`define PCSrcBusBits    2
`define OpBusBits       7
`define Funct3BusBits   3
`define Funct7BusBits   7
`define ImmSrcBusBits   3
`define AluCntrBusBits  4
`define ShamtBusBits    6
`define Shamt32BusBits  5
`define MemTypeBusBits  3
`define RsltSrcBusBits  3

// opcodes
`define LUI         7'b0110111
`define AUIPC       7'b0010111
`define JAL         7'b1101111
`define JALR        7'b1100111
`define BRANCH      7'b1100011
`define LOAD        7'b0000011
`define STORE       7'b0100011
`define OP_IMM      7'b0010011
`define OP          7'b0110011
`define OP_IMM_32   7'b0011011
`define OP_32       7'b0111011

// Funct3
`define Funct3BEQ   3'b000
`define Funct3BNE   3'b001
`define Funct3BLT   3'b100
`define Funct3BGE   3'b101
`define Funct3BLTU  3'b110
`define Funct3BGEU  3'b111
`define Funct3SRxI  3'b101

// ImmSrc
`define ImmSrcRType 3'bxxx
`define ImmSrcIType 3'b000
`define ImmSrcSType 3'b001
`define ImmSrcBType 3'b010
`define ImmSrcUType 3'b011
`define ImmSrcJType 3'b100

// ALUControl
`define ALUAdd  4'b0000
`define ALUSub	4'b1000
`define ALUSll	4'b0001
`define ALUSlt	4'b0010
`define ALUSltu	4'b0011
`define ALUXor	4'b0100
`define ALUSrl	4'b0101
`define ALUSra	4'b1101
`define ALUOr	4'b0110
`define ALUAnd	4'b0111

// MemType
`define MemTypeB    3'b000
`define MemTypeH    3'b001
`define MemTypeW    3'b010
`define MemTypeD    3'b011
`define MemTypeBU   3'b100
`define MemTypeHU   3'b101
`define MemTypeWU   3'b110

`endif