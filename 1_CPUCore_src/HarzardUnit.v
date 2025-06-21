`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: HarzardUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Deal with harzards in pipline
//////////////////////////////////////////////////////////////////////////////////
module HarzardUnit(
    input wire CpuRst, ICacheMiss, DCacheMiss, 
    input wire BranchE, JalrE, JalD, 
    input wire [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdMW,
    input wire [1:0] RegReadE,
    input wire MemToRegE,
    input wire [2:0] RegWriteMW,
    output reg StallF, FlushF, StallD, FlushD, StallE, FlushE,  StallMW, FlushMW,
    output reg Forward1E, Forward2E
    );
    wire is_load_MW = (RegWriteMW == 3'd1 || RegWriteMW == 3'd2 || RegWriteMW == 3'd3 || 
                       RegWriteMW == 3'd4 || RegWriteMW == 3'd5);

    always @(*) begin
        // 重置处理
        if (CpuRst) begin
            FlushF = 1; FlushD = 1; FlushE = 1; FlushMW = 1;
            StallF = 0; StallD = 0; StallE = 0; StallMW = 0;
            Forward1E = 0; Forward2E = 0;
        end else begin
            // 默认值
            StallF = 0; FlushF = 0; StallD = 0; FlushD = 0;
            StallE = 0; FlushE = 0; StallMW = 0; FlushMW = 0;
            Forward1E = 0; Forward2E = 0;

            // 控制冒险
            if (JalD)
                FlushE = 1; // 对于 JAL，清空 EX 阶段
            if (BranchE || JalrE) begin
                FlushF = 1; FlushD = 1; // 对于分支或 JALR，清空 IF 和 ID 阶段
            end

            // 加载使用冒险
            if (MemToRegE && ((Rs1D == RdE && RegReadE[1]) || (Rs2D == RdE && RegReadE[0]))) begin
                StallD = 1; FlushE = 1; StallF = 1; // 暂停 ID，清空 EX，暂停 IF
            end

            // 从 MW 阶段到 EX 阶段的前递
            if (Rs1E == RdMW && RegWriteMW != 0 && !is_load_MW && RdMW != 0)
                Forward1E = 1;
            if (Rs2E == RdMW && RegWriteMW != 0 && !is_load_MW && RdMW != 0)
                Forward2E = 1;
        end
    end
    //Stall and Flush signals generate

    //Forward Register Source 1

    //Forward Register Source 2

endmodule

//Function Description
    //The HazardUnit is used to handle pipeline conflicts. It resolves data-related and control-related issues by inserting bubbles, forwarding, and flushing pipeline segments through combinational logic circuits.
    //During the early stage of testing the CPU's correctness, four empty instructions can be inserted between every two instructions, and then the output of this module can be set to not forward, not stall, and not flush. 
//Inputs
    //CpuRst													External signal, used to initialize the CPU. When CpuRst = 1, the CPU global reset clears all segment registers (flushes all segments), and when CpuRst = 0, the CPU starts executing instructions
    //ICacheMiss, DCacheMiss									Reserved signals for subsequent experiments. They can be ignored temporarily. They are used to handle cache misses.
    //BranchE, JalrE, JalD											Used to handle control-related issues.
    //Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdMW							Used to handle data-related issues. Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdMW represent the numbers of source registers 1, source registers 2, target register numbers respectively.
    //RegReadE RegReadD[1]==1									Indicates that the value of the register corresponding to A1 has been used. RegReadD[0] = 1 indicates that the value of the register corresponding to A2 has been used, used for forward processing.
    //RegWriteMW												Used to handle data-related issues. RegWrite != 3'b0 indicates that there is a write operation to the target register.
    //MemToRegE												Indicates that the current instruction in the Ex segment loads data from the Data Memory to the register.
//Outputs
    //StallF, FlushF, StallD, FlushD, StallE, FlushE, StallMW, FlushMW	Controls the four segment registers for stall (maintaining the state unchanged) and flush (clearing).
    //Forward1E, Forward2E										Controls forward.
//Experimental Requirements  
    //Implement the HazardUnit module   