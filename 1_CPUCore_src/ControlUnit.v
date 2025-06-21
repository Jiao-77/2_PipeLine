`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
`include "Parameters.v"   
`define ControlOut {{JalD,JalrD},{MemToRegD},{RegWriteD},{MemWriteD},{LoadNpcD},{RegReadD},{BranchTypeD},{AluContrlD},{AluSrc1D,AluSrc2D},{ImmType}}
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,
    output reg JalD,
    output reg JalrD,
    output reg [2:0] RegWriteD,
    output reg MemToRegD,
    output reg [3:0] MemWriteD,
    output reg LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    output reg [1:0] AluSrc2D,
    output reg AluSrc1D,
    output reg [2:0] ImmType
    );
    always @(*) begin
        // Defaults
        JalD = 0; JalrD = 0; RegWriteD = `NOREGWRITE; MemToRegD = 0;
        MemWriteD = 4'b0; LoadNpcD = 0; RegReadD = 2'b00;
        BranchTypeD = `NOBRANCH; AluContrlD = 4'b0; AluSrc1D = 0;
        AluSrc2D = 2'b00; ImmType = `RTYPE;

        case (Op)
            7'b0110011: begin // R-type
                RegWriteD = `LW; RegReadD = 2'b11;
                case (Fn3)
                    3'b000: AluContrlD = (Fn7 == 7'b0000000) ? `ADD : `SUB;
                    3'b001: AluContrlD = `SLL;
                    3'b010: AluContrlD = `SLT;
                    3'b011: AluContrlD = `SLTU;
                    3'b100: AluContrlD = `XOR;
                    3'b101: AluContrlD = (Fn7 == 7'b0000000) ? `SRL : `SRA;
                    3'b110: AluContrlD = `OR;
                    3'b111: AluContrlD = `AND;
                endcase
            end
            7'b0010011: begin // I-type immediate
                RegWriteD = `LW; RegReadD = 2'b10; AluSrc2D = 2'b01; ImmType = `ITYPE;
                case (Fn3)
                    3'b000: AluContrlD = `ADD;
                    3'b010: AluContrlD = `SLT;
                    3'b011: AluContrlD = `SLTU;
                    3'b100: AluContrlD = `XOR;
                    3'b110: AluContrlD = `OR;
                    3'b111: AluContrlD = `AND;
                    3'b001: AluContrlD = `SLL;
                    3'b101: AluContrlD = (Fn7 == 7'b0000000) ? `SRL : `SRA;
                endcase
            end
            7'b0000011: begin // Load
                RegWriteD = Fn3 == 3'b000 ? `LB : Fn3 == 3'b001 ? `LH :
                            Fn3 == 3'b010 ? `LW : Fn3 == 3'b100 ? `LBU :
                            Fn3 == 3'b101 ? `LHU : `NOREGWRITE;
                MemToRegD = 1; RegReadD = 2'b10; AluSrc2D = 2'b01;
                ImmType = `ITYPE; AluContrlD = `ADD;
            end
            7'b0100011: begin // Store
                MemWriteD = Fn3 == 3'b000 ? 4'b0001 : Fn3 == 3'b001 ? 4'b0011 :
                            Fn3 == 3'b010 ? 4'b1111 : 4'b0000;
                RegReadD = 2'b11; AluSrc2D = 2'b01; ImmType = `STYPE; AluContrlD = `ADD;
            end
            7'b1100011: begin // Branch
                BranchTypeD = Fn3; RegReadD = 2'b11; ImmType = `BTYPE;
            end
            7'b1101111: begin // JAL
                JalD = 1; RegWriteD = `LW; LoadNpcD = 1; ImmType = `JTYPE;
            end
            7'b1100111: begin // JALR
                JalrD = 1; RegWriteD = `LW; LoadNpcD = 1; RegReadD = 2'b10;
                AluSrc2D = 2'b01; ImmType = `ITYPE; AluContrlD = `ADD;
            end
            7'b0010111: begin // AUIPC
                RegWriteD = `LW; AluSrc1D = 1; AluSrc2D = 2'b01;
                ImmType = `UTYPE; AluContrlD = `ADD;
            end
            7'b0110111: begin // LUI
                RegWriteD = `LW; AluSrc2D = 2'b01; ImmType = `UTYPE; AluContrlD = `LUI;
            end
        endcase
    end
endmodule

//Function Description
    //ControlUnit			is the instruction decoder and combinational logic circuit of this CPU.
//Inputs
    // Op					is the opcode part of the instruction.
    // Fn3					is the func3 part of the instruction.
    // Fn7					is the func7 part of the instruction.
//Outputs
    // JalD==1				indicates that the Jal instruction has reached the ID decoding stage.
    // JalrD==1			indicates that the Jalr instruction has reached the ID decoding stage.
    // RegWriteD			indicates the register write mode corresponding to the instruction in the ID stage. All modes are defined in Parameters.v.
    // MemToRegD==1		indicates that the instruction in the ID stage needs to write the value read from the data memory into the register.
    // MemWriteD			4 bits, using one-hot code format. For the 32-bit word of the data memory, it is written byte by byte. MemWriteD = 0001 indicates that only the lowest 1 byte is written, similar to the interface with Xilinx BRAM.
    // LoadNpcD==1		indicates that the NextPC is output to ResultM.
    // RegReadD[1]==1		indicates that the value of the register corresponding to A1 is used. RegReadD[0] == 1 indicates that the value of the register corresponding to A2 is used, for forward processing.
    // BranchTypeD			indicates different branch types. All types are defined in Parameters.v.
    // AluContrlD			indicates different ALU calculation functions. All types are defined in Parameters.v.
    // AluSrc2D			indicates the selection of the 2nd input source of the Alu.
    // AluSrc1D			indicates the selection of the 1st input source of the Alu.
    // ImmType			indicates the format of the immediate number of the instruction. All types are defined in Parameters.v.   
//Experimental Requirements  
    //Implement the ControlUnit module   