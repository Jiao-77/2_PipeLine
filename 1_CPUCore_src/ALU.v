`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: ALU
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: ALU unit of RISCV CPU
//////////////////////////////////////////////////////////////////////////////////
`include "Parameters.v"   
module ALU(
    input wire [31:0] Operand1,
    input wire [31:0] Operand2,
    input wire [3:0] AluContrl,
    output reg [31:0] AluOut
    );
    always @(*) begin
        case (AluContrl)
            `SLL:  AluOut = Operand1 << Operand2[4:0];
            `SRL:  AluOut = Operand1 >> Operand2[4:0];
            `SRA:  AluOut = $signed(Operand1) >>> Operand2[4:0];
            `ADD:  AluOut = Operand1 + Operand2;
            `SUB:  AluOut = Operand1 - Operand2;
            `XOR:  AluOut = Operand1 ^ Operand2;
            `OR:   AluOut = Operand1 | Operand2;
            `AND:  AluOut = Operand1 & Operand2;
            `SLT:  AluOut = ($signed(Operand1) < $signed(Operand2)) ? 32'b1 : 32'b0;
            `SLTU: AluOut = (Operand1 < Operand2) ? 32'b1 : 32'b0;
            `LUI:  AluOut = Operand2;
            default: AluOut = 32'bx;
        endcase
    end
endmodule

//Function and Interface Description
	//The ALU takes in two operands and performs different calculation operations based on the value of AluContrl. The calculation results are then output to AluOut.
	//The type definition of AluContrl is provided in Parameters.v.
//Recommended format: 
    //case()
    //    `ADD:        AluOut<=Operand1 + Operand2; 
    //   	.......
    //    default:    AluOut <= 32'hxxxxxxxx;                          
    //endcase
//Experimental Requirements  
    //Implement the ALU module