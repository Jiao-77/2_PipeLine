`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: DataRam
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: A Verilog-based synchronous dual-port RAM which can be 
//              synthesized as BRAM. [FIXED VERSION]
//
// --- ��Ҫ�޸�˵�� (Key Fixes) ---
// 1. [������] ��������Ϊͬ���� (always @(posedge clk))��������BRAM�ƶ�Ҫ��
//    ������ۺϴ��� [Synth 8-2914]��
// 2. [������] ������д�����ϲ���һ��always���У�����˴���Ŀɶ��Ժ͹淶�ԡ�
// 3. [���Ƴ�] �Ƴ��˲����ۺϵ� initial �������ĸ�ֵ��
//////////////////////////////////////////////////////////////////////////////////
module DataRam(
    input             clk,
    input  [ 3:0]     wea, 
    input  [ 3:0]     web,
    input  [31:2]     addra, 
    input  [31:2]     addrb,
    input  [31:0]     dina, 
    input  [31:0]     dinb,
    output reg [31:0] douta, 
    output reg [31:0] doutb
);

    // BRAM �洢����
    reg [31:0] ram_cell [0:4095];

    // ��ַ��Ч�Լ��
    wire addra_valid = ( addra[31:14] == 18'h0 );
    wire addrb_valid = ( addrb[31:14] == 18'h0 );
    
    // ��ַӳ�䵽BRAM�ڲ���ַ
    wire [11:0] addral = addra[13:2];
    wire [11:0] addrbl = addrb[13:2];
    
    // ����ʱ�����ݳ�ʼ�� (���ۺϵ�д��)
    initial begin
        $readmemh("1_PipelineLab/2_Simulation/T22data.txt", ram_cell);
    end

    // --- ͬ����д�߼� ---
    // Port A �Ĳ���
    always @(posedge clk) begin
        // ������ (ͬ����)
        if (addra_valid) begin
            douta <= ram_cell[addral];
        end

        // д���� (ͬ��д�����ֽ�ʹ��)
        if (addra_valid) begin
            if (wea[0]) ram_cell[addral][ 7: 0] <= dina[ 7: 0];
            if (wea[1]) ram_cell[addral][15: 8] <= dina[15: 8];
            if (wea[2]) ram_cell[addral][23:16] <= dina[23:16];
            if (wea[3]) ram_cell[addral][31:24] <= dina[31:24];
        end
    end

    // Port B �Ĳ���
    always @(posedge clk) begin
        // ������ (ͬ����)
        if (addrb_valid) begin
            doutb <= ram_cell[addrbl];
        end

        // д���� (ͬ��д�����ֽ�ʹ��)
        if (addrb_valid) begin
            if (web[0]) ram_cell[addrbl][ 7: 0] <= dinb[ 7: 0];
            if (web[1]) ram_cell[addrbl][15: 8] <= dinb[15: 8];
            if (web[2]) ram_cell[addrbl][23:16] <= dinb[23:16];
            if (web[3]) ram_cell[addrbl][31:24] <= dinb[31:24];
        end
    end

endmodule
