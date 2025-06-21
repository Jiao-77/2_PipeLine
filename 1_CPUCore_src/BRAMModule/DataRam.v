`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: DataRam
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: A Verilog-based synchronous dual-port RAM which can be 
//              synthesized as BRAM. [FIXED VERSION]
//
// --- 主要修复说明 (Key Fixes) ---
// 1. [已修正] 读操作改为同步读 (always @(posedge clk))，以满足BRAM推断要求，
//    解决了综合错误 [Synth 8-2914]。
// 2. [已修正] 将所有写操作合并到一个always块中，提高了代码的可读性和规范性。
// 3. [已移除] 移除了不可综合的 initial 块对输出的赋值。
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

    // BRAM 存储阵列
    reg [31:0] ram_cell [0:4095];

    // 地址有效性检查
    wire addra_valid = ( addra[31:14] == 18'h0 );
    wire addrb_valid = ( addrb[31:14] == 18'h0 );
    
    // 地址映射到BRAM内部地址
    wire [11:0] addral = addra[13:2];
    wire [11:0] addrbl = addrb[13:2];
    
    // 仿真时的数据初始化 (可综合的写法)
    initial begin
        $readmemh("1_PipelineLab/2_Simulation/T22data.txt", ram_cell);
    end

    // --- 同步读写逻辑 ---
    // Port A 的操作
    always @(posedge clk) begin
        // 读操作 (同步读)
        if (addra_valid) begin
            douta <= ram_cell[addral];
        end

        // 写操作 (同步写，按字节使能)
        if (addra_valid) begin
            if (wea[0]) ram_cell[addral][ 7: 0] <= dina[ 7: 0];
            if (wea[1]) ram_cell[addral][15: 8] <= dina[15: 8];
            if (wea[2]) ram_cell[addral][23:16] <= dina[23:16];
            if (wea[3]) ram_cell[addral][31:24] <= dina[31:24];
        end
    end

    // Port B 的操作
    always @(posedge clk) begin
        // 读操作 (同步读)
        if (addrb_valid) begin
            doutb <= ram_cell[addrbl];
        end

        // 写操作 (同步写，按字节使能)
        if (addrb_valid) begin
            if (web[0]) ram_cell[addrbl][ 7: 0] <= dinb[ 7: 0];
            if (web[1]) ram_cell[addrbl][15: 8] <= dinb[15: 8];
            if (web[2]) ram_cell[addrbl][23:16] <= dinb[23:16];
            if (web[3]) ram_cell[addrbl][31:24] <= dinb[31:24];
        end
    end

endmodule
