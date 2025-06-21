`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: InstructionRamWrapper
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: a Verilog-based ram which can be systhesis as BRAM
// 
//////////////////////////////////////////////////////////////////////////////////
module InstructionRam(
    input  clk,
    input  web,
    input  [31:2] addra, addrb,
    input  [31:0] dinb,
    output reg [31:0] douta, doutb
);
initial begin douta=0; doutb=0; end

wire addra_valid = ( addra[31:14]==18'h0 );
wire addrb_valid = ( addrb[31:14]==18'h0 );
wire [11:0] addral = addra[13:2];
wire [11:0] addrbl = addrb[13:2];

reg [31:0] ram_cell [0:4095];

initial begin    // you can add simulation instructions here
    ram_cell[0] = 32'h00000000;
        // ......
end

always @ (posedge clk)
    douta <= addra_valid ? ram_cell[addral] : 0;
    
always @ (posedge clk)
    doutb <= addrb_valid ? ram_cell[addrbl] : 0;

always @ (posedge clk)
    if(web & addrb_valid) 
        ram_cell[addrbl] <= dinb;

endmodule

// Function Description
    // Synchronous read and write to BRAM. Port A is read-only for fetching instructions, while Port B is writable for external debug_module's read and write operations.
    // Write enable is 1-bit and byte write is not supported.
// Inputs
    // clk                  Input clock
    // addra             Address for reading from Port A
    // addrb             Read/write address for Port B
    // dinb              Write input data for Port B
    // web               Write enable for Port B
// Outputs
    // douta             Data for reading from Port A
    // doutb             Data for reading from Port B
// Experimental Requirements
    // No modifications are needed.