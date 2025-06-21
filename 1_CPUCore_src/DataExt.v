`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: DataExt 
// Target Devices: 
// Tool Versions: 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

`include "Parameters.v"   
module DataExt(
    input wire [31:0] IN,
    input wire [1:0] LoadedBytesSelect,
    input wire [2:0] RegWriteMW,
    output reg [31:0] OUT
    );    
    always @(*) begin
        case (RegWriteMW)
            `LW: OUT = IN;
            `LB: case (LoadedBytesSelect)
                2'b00: OUT = {{24{IN[7]}}, IN[7:0]};
                2'b01: OUT = {{24{IN[15]}}, IN[15:8]};
                2'b10: OUT = {{24{IN[23]}}, IN[23:16]};
                2'b11: OUT = {{24{IN[31]}}, IN[31:24]};
            endcase
            `LH: case (LoadedBytesSelect)
                2'b00: OUT = {{16{IN[15]}}, IN[15:0]};
                2'b01: OUT = {{16{IN[23]}}, IN[23:8]};
                2'b10: OUT = {{16{IN[31]}}, IN[31:16]};
                2'b11: OUT = {{16{IN[31]}}, IN[31:24], IN[7:0]}; // Misaligned, partial
            endcase
            `LBU: case (LoadedBytesSelect)
                2'b00: OUT = {24'b0, IN[7:0]};
                2'b01: OUT = {24'b0, IN[15:8]};
                2'b10: OUT = {24'b0, IN[23:16]};
                2'b11: OUT = {24'b0, IN[31:24]};
            endcase
            `LHU: case (LoadedBytesSelect)
                2'b00: OUT = {16'b0, IN[15:0]};
                2'b01: OUT = {16'b0, IN[23:8]};
                2'b10: OUT = {16'b0, IN[31:16]};
                2'b11: OUT = {16'b0, IN[31:24], IN[7:0]}; // Misaligned, partial
            endcase
            default: OUT = 32'b0;
        endcase
    end
endmodule

//Function Description
    //DataExt				is designed to handle the situation of non-aligned load operations, and to perform signed or unsigned expansion on the number of loads in Data Mem based on different load modes. It is a combinational logic circuit.
//Input
    //IN					is a 32-bit word loaded from Data Memory
    //LoadedBytesSelect		is equivalent to AluOutMW[1:0], which is the low two bits of the address read from Data Memory.
                            //Since Data Memory is accessed in units of words (32 bits), the byte address needs to be converted to a word address and passed to DataMem
                            //DataMem returns one word at a time. The low two bits of the address are used to select the required bytes from the 32-bit word
    //RegWriteMW			represents different register write modes. All modes are defined in Parameters.v
//Output
    //OUT					represents the final value to be written to the register
//Experimental Requirements  
    //Implement the DataExt module  