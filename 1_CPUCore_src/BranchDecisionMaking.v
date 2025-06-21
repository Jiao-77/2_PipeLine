`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: BranchDecisionMaking
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Decide whether to branch 
//////////////////////////////////////////////////////////////////////////////////
`include "Parameters.v"   
module BranchDecisionMaking(
    input wire [2:0] BranchTypeE,
    input wire [31:0] Operand1,Operand2,
    output reg BranchE
    );
    always @(*) begin
        case (BranchTypeE)
            `NOBRANCH: BranchE = 1'b0;
            `BEQ:      BranchE = (Operand1 == Operand2);
            `BNE:      BranchE = (Operand1 != Operand2);
            `BLT:      BranchE = ($signed(Operand1) < $signed(Operand2));
            `BLTU:     BranchE = (Operand1 < Operand2);
            `BGE:      BranchE = ($signed(Operand1) >= $signed(Operand2));
            `BGEU:     BranchE = (Operand1 >= Operand2);
            default:   BranchE = 1'b0;
        endcase
    end
endmodule

//Function and Interface Description
    //BranchDecisionMaking takes two operands as input. Depending on the value of BranchTypeE, it performs different judgments. When the branch should be taken, BranchE is set to 1'b1.
    //The type definition of BranchTypeE is provided in Parameters.v.
//Recommended format:
    //case()
    //    `BEQ: ???
    //      .......
    //    default:                            BranchE<=1'b0;  //NOBRANCH
    //endcase
//Experimental Requirements  
    //Implement the BranchDecisionMaking module