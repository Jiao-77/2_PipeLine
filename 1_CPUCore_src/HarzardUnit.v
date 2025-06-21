`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: HarzardUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Deal with harzards in pipline [FIXED VERSION]
//
// --- 主要修复说明 (Key Fixes) ---
// 1. [已修正] 控制冒险: `JalD` 现在正确地刷新IF阶段 (`FlushF`) 而不是EX阶段。
// 2. [已修正] 数据转发: 新增了至关重要的 EX -> EX 转发逻辑。
//    - `Forward1E`/`Forward2E` 输出现在是2位宽，以支持从不同阶段转发。
//      (00:不转发, 01:从MEM/WB转发, 10:从EX转发)
//    - *注意: 这是必要的修改，如果您的数据通路只支持1位转发信号，
//      则无法完整处理所有数据冒险，需要修改数据通路以支持2位转发控制。*
// 3. [已修正] 转发优先级: 明确了EX->EX转发比MEM/WB->EX转发具有更高的优先级。
// 4. [已修正] Load-Use冒险: 逻辑更清晰，并与转发逻辑正确地协同工作，
//    避免在不必要的情况下暂停。
// 5. [新增输入] `RegWriteE`: 为了实现EX->EX转发，必须知道EX阶段的指令是否
//    会写回寄存器。这是原代码缺失的关键信号。
//////////////////////////////////////////////////////////////////////////////////
module HarzardUnit(
    input wire        CpuRst, 
    input wire        ICacheMiss, 
    input wire        DCacheMiss,
    input wire        BranchE, 
    input wire        JalrE, 
    input wire        JalD,
    input wire [4:0]  Rs1D, 
    input wire [4:0]  Rs2D, 
    input wire [4:0]  Rs1E, 
    input wire [4:0]  Rs2E, 
    input wire [4:0]  RdE, 
    input wire [4:0]  RdMW,
    input wire [1:0]  RegReadE,     // 假设: 这是ID阶段的读使能信号 (RegReadD)
    input wire        RegWriteE,    // **[新增/必要]** EX阶段的写回使能信号
    input wire        MemToRegE,
    input wire [2:0]  RegWriteMW,
    output reg        StallF, 
    output reg        FlushF, 
    output reg        StallD, 
    output reg        FlushD, 
    output reg        StallE, 
    output reg        FlushE, 
    output reg        StallMW, 
    output reg        FlushMW,
    output reg [1:0]  Forward1E,    // **[修改/必要]** 修改为2位以支持多种转发源
    output reg [1:0]  Forward2E     // **[修改/必要]** 修改为2位以支持多种转发源
    );

    // --- 诊断与假设 ---
    // 您的原代码中 `RegReadE` 用于判断ID阶段的指令是否读寄存器，这表明其命名可能
    // 应该是 `RegReadD`。本代码基于此假设进行设计。如果该信号确实来自EX阶段，
    // 则需要相应调整。
    wire load_use_hazard = MemToRegE && (RdE != 5'd0) && 
                           ((RdE == Rs1D && RegReadE[1]) || (RdE == Rs2D && RegReadE[0]));

    always @(*) begin
        // --- 默认值 ---
        // 在每个周期开始时，都先假设没有冒险发生
        StallF  = 1'b0; FlushF  = 1'b0;
        StallD  = 1'b0; FlushD  = 1'b0;
        StallE  = 1'b0; FlushE  = 1'b0;
        StallMW = 1'b0; FlushMW = 1'b0;
        Forward1E = 2'b00; // 00: 不转发
        Forward2E = 2'b00; // 00: 不转发

        // --- 复位逻辑 ---
        if (CpuRst) begin
            FlushF = 1'b1; FlushD = 1'b1; FlushE = 1'b1; FlushMW = 1'b1;
        end 
        else begin
            // --- 冒险处理逻辑 (按优先级排列) ---

            // ** 1. 数据冒险：加载/使用 (Load-Use Hazard) **
            // 最高优先级的数据冒险。当EX阶段的指令是LW，且其目标寄存器是ID阶段
            // 指令的源寄存器时，必须暂停流水线一个周期。
            if (load_use_hazard) begin
                StallF = 1'b1; // 暂停PC和IF/ID寄存器
                StallD = 1'b1;
                FlushE = 1'b1; // 在ID/EX寄存器中插入气泡 (nop)
            end 
            else begin
                // --- 如果没有Load-Use暂停，则处理转发和控制冒险 ---

                // ** 2. 数据冒险：写后读 (RAW) - 转发逻辑 **

                // ** 优先级 1: EX -> EX 转发 **
                // 条件: EX阶段的指令会写寄存器(ALU操作等)，其目标寄存器是当前EX阶段所需
                // 的源寄存器。这是最高优先级的转发，因为EX阶段的结果比MEM/WB阶段的更新。
                if (RegWriteE && (RdE != 5'd0)) begin
                    if (RdE == Rs1E) begin
                        Forward1E = 2'b10; // 10: 从EX阶段转发
                    end
                    if (RdE == Rs2E) begin
                        Forward2E = 2'b10; // 10: 从EX阶段转发
                    end
                end

                // ** 优先级 2: MEM/WB -> EX 转发 **
                // 条件: MEM/WB阶段的指令会写寄存器，其目标寄存器是当前EX阶段所需的源寄存器，
                // 且这个依赖没有被更高优先级的 EX -> EX 转发所解决。
                if (RegWriteMW != 3'b0 && (RdMW != 5'd0)) begin
                    if ((RdMW == Rs1E) && (Forward1E == 2'b00)) begin // 仅当未被EX->EX转发时
                        Forward1E = 2'b01; // 01: 从MEM/WB阶段转发
                    end
                    if ((RdMW == Rs2E) && (Forward2E == 2'b00)) begin // 仅当未被EX->EX转发时
                        Forward2E = 2'b01; // 01: 从MEM/WB阶段转发
                    end
                end

                // ** 3. 控制冒险 (Control Hazards) **
                // 条件: 分支或跳转发生时，需要作废流水线中已错误取入的指令。

                // JAL在ID阶段确定跳转地址，需要刷新IF阶段的指令。
                if (JalD) begin
                    FlushF = 1'b1; // [修正] 原为FlushE，是错误的。
                end

                // 分支或JALR在EX阶段确定跳转，需要刷新IF和ID两个阶段的指令。
                if (BranchE || JalrE) begin
                    FlushF = 1'b1;
                    FlushD = 1'b1;
                end
            end
        end
    end

endmodule
