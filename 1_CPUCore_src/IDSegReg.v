`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: IDSegReg
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: IF-ID Segment Register
//////////////////////////////////////////////////////////////////////////////////
module IDSegReg(
    input wire clk,
    input wire clear,
    input wire en,
    //Instrution Memory Access
    input wire [31:0] A,
    output wire [31:0] RD,
    //Instruction Memory Debug
    input wire [31:0] A2,
    input wire [31:0] WD2,
    input wire [3:0] WE2,
    output wire [31:0] RD2,
    //
    input wire [31:0] PCF,
    output reg [31:0] PCD 
    );
    
    initial PCD = 0;
    always@(posedge clk)
        if(en)
            PCD <= clear ? 0: PCF;
    
    wire [31:0] RD_raw;
    InstructionRam InstructionRamInst (
         .clk    ( clk ),                        	//Please complete the code!!!
         .addra  ( A[31:2]),                       //Please complete the code!!!
         .douta  ( RD_raw     ),
         .web    ( |WE2       ),
         .addrb  ( A2[31:2]   ),
         .dinb   ( WD2        ),
         .doutb  ( RD2        )
     );
    // Add clear and stall support
    // if chip not enabled, output output last read result
    // else if chip clear, output 0
    // else output values from bram
    reg stall_ff= 1'b0;
    reg clear_ff= 1'b0;
    reg [31:0] RD_old=32'b0;
    always @ (posedge clk)
    begin
        stall_ff<=~en;
        clear_ff<=clear;
        RD_old<=RD_raw;
    end    
    assign RD = stall_ff ? RD_old : (clear_ff ? 32'b0 : RD_raw );

endmodule

//Function Description
    // IDSegReg is an IF-ID segment register, which simultaneously incorporates a synchronous read-write BRAM (here you can invoke the InstructionRam provided by us. It will be automatically synthesized into a block memory, or you can alternatively invoke the BRAM IP core from Xilinx).
    // Synchronous read memory is equivalent to asynchronous read memory with an external D trigger. Data can only be read when the clock edge rises.
    // At this point, if the data is cached through the segment register, then two clock rising edges are required to transfer the data to the Ex segment.
    // Therefore, when calling this synchronous memory in the segment register module, directly pass the output to the ID segment combinational logic.
    // After calling the mem module, the output is RD_raw. Through the assignment RD = stall_ff ? RD_old : (clear_ff ? 32'b0 : RD_raw );
    // Thus achieving the functions of RD segment register stall and clear
//Experimental requirements  
    //You need to complete the above code. The fragment to be completed is as follows
    //InstructionRam InstructionRamInst (
    //     .clk    (),                          // Please complete the code
    //     .addra  (),                       // Please complete the code
    //     .douta  ( RD_raw     ),
    //     .web    ( |WE2       ),
    //     .addrb  ( A2[31:2]   ),
    //     .dinb   ( WD2        ),
    //     .doutb  ( RD2        )
    // );
//Notes
    //The addra input to DataRam is a word address, and each word consists of 32 bits.