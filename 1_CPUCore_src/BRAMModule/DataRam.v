`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: InstructionRamWrapper
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: a Verilog-based ram which can be systhesis as BRAM
// 
//////////////////////////////////////////////////////////////////////////////////
module DataRam(
    input  clk,
    input  [ 3:0] wea, web,
    input  [31:2] addra, addrb,
    input  [31:0] dina , dinb,
    output reg [31:0] douta, doutb
);
initial begin douta=0; doutb=0; end

wire addra_valid = ( addra[31:14]==18'h0 );
wire addrb_valid = ( addrb[31:14]==18'h0 );
wire [11:0] addral = addra[13:2];
wire [11:0] addrbl = addrb[13:2];

reg [31:0] ram_cell [0:4095];

initial begin    // add simulation data here
    ram_cell[0] = 32'h00000000;
    // ......
end

always @ (*)
    douta <= addra_valid ? ram_cell[addral] : 0;
    
always @ (*)
    doutb <= addrb_valid ? ram_cell[addrbl] : 0;

always @ (posedge clk)
    if(wea[0] & addra_valid) 
        ram_cell[addral][ 7: 0] <= dina[ 7: 0];
        
always @ (posedge clk)
    if(wea[1] & addra_valid) 
        ram_cell[addral][15: 8] <= dina[15: 8];
        
always @ (posedge clk)
    if(wea[2] & addra_valid) 
        ram_cell[addral][23:16] <= dina[23:16];
        
always @ (posedge clk)
    if(wea[3] & addra_valid) 
        ram_cell[addral][31:24] <= dina[31:24];
        
always @ (posedge clk)
    if(web[0] & addrb_valid) 
        ram_cell[addrbl][ 7: 0] <= dinb[ 7: 0];
                
always @ (posedge clk)
    if(web[1] & addrb_valid) 
        ram_cell[addrbl][15: 8] <= dinb[15: 8];
                
always @ (posedge clk)
    if(web[2] & addrb_valid) 
        ram_cell[addrbl][23:16] <= dinb[23:16];
                
always @ (posedge clk)
    if(web[3] & addrb_valid) 
        ram_cell[addrbl][31:24] <= dinb[31:24];

endmodule

// Function Description
    // Synchronous read and write to BRAM, with dual-port functionality for both read and write operations. Port A is accessible by the CPU for data reading and writing, while Port B is used for external debug_module's read and write operations.
    // Write enable is 4-bit and supports byte write.
// Input
    // clk               Input clock
    // addra             Address for read/write operation on Port A
    // dina              Data input for write operation on Port A
    // wea               Write enable for Port A
    // addrb             Address for read/write operation on Port B
    // dinb              Data input for write operation on Port B
    // web               Write enable for Port B
// Output
    // douta             Data read from Port A
    // doutb             Data read from Port B
// Experimental Requirements
    // No modification is required