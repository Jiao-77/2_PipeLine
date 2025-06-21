`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: ImmOperandUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Generate different type of Immediate Operand
//////////////////////////////////////////////////////////////////////////////////
`include "Parameters.v"   
module ImmOperandUnit(
    input wire [31:7] In,
    input wire [2:0] Type,
    output reg [31:0] Out
    );
    always @(*) begin
        case (Type)
            `RTYPE: Out = 32'b0;
            `ITYPE: Out = {{20{In[31]}}, In[31:20]};
            `STYPE: Out = {{20{In[31]}}, In[31:25], In[11:7]};
            `BTYPE: Out = {{19{In[31]}}, In[31], In[7], In[30:25], In[11:8], 1'b0};
            `UTYPE: Out = {In[31:12], 12'b0};
            `JTYPE: Out = {{11{In[31]}}, In[31], In[19:12], In[20], In[30:21], 1'b0};
            default: Out = 32'b0;
        endcase
    end
endmodule

//Function Description
    //The ImmOperandUnit generates different types of 32-bit immediate numbers based on the partial encoded values of the currently decoded instruction.
//Input
    //IN		is the partial encoded values of the instruction except for the opcode.
    //Type		indicates the type of immediate number encoding, and all types are defined in Parameters.v.
//Output
    //OUT		represents the actual 32-bit value of the immediate number corresponding to the instruction.
//Experimental Requirements  
    //Complete the ImmOperandUnit module  
    //The following code needs to be completed:

    //always@(*)
    //begin
    //    case(Type)
    //        `ITYPE: Out<={ {21{In[31]}}, In[30:20] };
    //        //......                                        Please complete the code!!!
    //        default:Out<=32'hxxxxxxxx;
    //    endcase
    //end