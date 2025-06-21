`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: MEMSegReg
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: EX-MEM Segment Register
//////////////////////////////////////////////////////////////////////////////////
module MWSegReg(
    input wire clk,
    input wire en,
    input wire clear,
    //Data Signals
    input wire [31:0] AluOutE,
    output reg [31:0] AluOutMW, 
    input wire [31:0] ForwardData2,
    input wire [4:0] RdE,
    output reg [4:0] RdMW,
    input wire [31:0] PCE,
    output reg [31:0] PCMW,
    output wire [31:0] RD,
    //Data Memory Debug
    input wire [31:0] A2,
    input wire [31:0] WD2,
    input wire [3:0] WE2,
    output wire [31:0] RD2,
    //Control Signals
    input wire [3:0] MemWriteE,
    input wire [2:0] RegWriteE,
    output reg [2:0] RegWriteMW,
    input wire MemToRegE,
    output reg MemToRegMW,
    input wire LoadNpcE,
    output reg LoadNpcMW
    );
wire [31:0] RD_raw;
    reg [3:0] wea_actual;   // Changed to reg type
    reg [31:0] dina_actual; // Changed to reg type

    // Combinational logic for memory write control
    always @(*) begin
        case (MemWriteE)
            4'b0001: // SB (Store Byte)
                case (AluOutE[1:0])
                    2'b00: begin 
                        wea_actual = 4'b0001; 
                        dina_actual = {24'b0, ForwardData2[7:0]}; 
                    end
                    2'b01: begin 
                        wea_actual = 4'b0010; 
                        dina_actual = {16'b0, ForwardData2[7:0], 8'b0}; 
                    end
                    2'b10: begin 
                        wea_actual = 4'b0100; 
                        dina_actual = {8'b0, ForwardData2[7:0], 16'b0}; 
                    end
                    2'b11: begin 
                        wea_actual = 4'b1000; 
                        dina_actual = {ForwardData2[7:0], 24'b0}; 
                    end
                endcase
            4'b0011: // SH (Store Halfword)
                case (AluOutE[1:0])
                    2'b00: begin 
                        wea_actual = 4'b0011; 
                        dina_actual = {16'b0, ForwardData2[15:0]}; 
                    end
                    2'b01: begin 
                        wea_actual = 4'b0110; 
                        dina_actual = {8'b0, ForwardData2[15:0], 8'b0}; 
                    end
                    2'b10: begin 
                        wea_actual = 4'b1100; 
                        dina_actual = {ForwardData2[15:0], 16'b0}; 
                    end
                    2'b11: begin 
                        wea_actual = 4'b1000; 
                        dina_actual = {ForwardData2[7:0], 24'b0}; // Truncate to byte if misaligned
                    end
                endcase
            4'b1111: begin // SW (Store Word)
                wea_actual = 4'b1111; 
                dina_actual = ForwardData2;
            end
            default: begin 
                wea_actual = 4'b0000; 
                dina_actual = 32'b0; 
            end
        endcase
    end

    DataRam DataRamInst (
        .clk    (clk),
        .wea    (wea_actual),
        .addra  (AluOutE[31:2]),
        .dina   (dina_actual),
        .douta  (RD_raw),
        .web    (WE2),
        .addrb  (A2[31:2]),
        .dinb   (WD2),
        .doutb  (RD2)
    );

    reg stall_ff = 1'b0;
    reg clear_ff = 1'b0;
    reg [31:0] RD_old = 32'b0;
    always @(posedge clk) begin
        stall_ff <= ~en;
        clear_ff <= clear;
        RD_old <= RD_raw;
    end
    assign RD = stall_ff ? RD_old : (clear_ff ? 32'b0 : RD_raw);

    always @(posedge clk) begin
        if (en) begin
            if (clear) begin
                AluOutMW <= 32'b0; RdMW <= 5'b0; PCMW <= 32'b0;
                RegWriteMW <= 3'b0; MemToRegMW <= 1'b0; LoadNpcMW <= 1'b0;
            end else begin
                AluOutMW <= AluOutE; RdMW <= RdE; PCMW <= PCE;
                RegWriteMW <= RegWriteE; MemToRegMW <= MemToRegE; LoadNpcMW <= LoadNpcE;
            end
        end
    end
endmodule

//Function Description
    //MWSegReg is the fourth-stage register
    //Similar to the call and extension of Bram in IDSegReg.V, it also contains a synchronous read-write Bram (here you can call the example provided by us: DataRam, which will be automatically synthesized into block memory. You can also alternatively call the Xilinx BRAM IP core).
    //Example：DataRam DataRamInst (
    //    .clk    (),                         //Please complete the code!!!
    //    .wea    (),                       //Please complete the code!!!
    //    .addra  (),                      //Please complete the code!!!
    //    .dina   (),                       //Please complete the code!!!
    //    .douta  ( RD_raw         ),
    //    .web    ( WE2            ),
    //    .addrb  ( A2[31:2]       ),
    //    .dinb   ( WD2            ),
    //    .doutb  ( RD2            )
    //    );  

//Experimental Requirements  
    //Implement the MWSegReg module

//Notes
    //The address input to DataRam (addra) is a word address, which is 32 bits for each word.
    //Please implement non-byte-aligned byte load together with the DataExt module.
