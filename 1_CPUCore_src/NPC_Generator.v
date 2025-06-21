`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: NPC_Generator
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Choose Next PC value
//////////////////////////////////////////////////////////////////////////////////
module NPC_Generator(
    input wire [31:0] PCF,JalrTarget, BranchTarget, JalTarget,
    input wire BranchE,JalD,JalrE,
    output reg [31:0] PC_In
    );
    always @(*) begin
        if (JalrE)
            PC_In = JalrTarget;        // JALR target from EX stage
        else if (BranchE)
            PC_In = BranchTarget;      // Branch target from EX stage
        else if (JalD)
            PC_In = JalTarget;         // JAL target from ID stage
        else
            PC_In = PCF + 32'd4;       // Sequential execution
    end
endmodule

//Function Description
    //NPC_Generator is a module used to generate Next PC values. It selects different new PC values based on different jump signals.
//Inputs
    //PCF				The old PC value
    //JalrTarget		The corresponding jump target for the jalr instruction
    //BranchTarget		The corresponding jump target for the branch instruction
    //JalTarget			The corresponding jump target for the jal instruction
    //BranchE==1		The Branch instruction in the Ex stage determines the jump
    //JalD==1			The Jal instruction in the ID stage determines the jump
    //JalrE==1			The Jalr instruction in the Ex stage determines the jump
//Outputs
    //PC_In			The NPC value
//Experimental Requirements  
    //Implement the NPC_Generator module  
