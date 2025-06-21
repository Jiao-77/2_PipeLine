`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISCV-Pipline CPU
// Module Name: HarzardUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Deal with harzards in pipline [FIXED VERSION]
//
// --- ��Ҫ�޸�˵�� (Key Fixes) ---
// 1. [������] ����ð��: `JalD` ������ȷ��ˢ��IF�׶� (`FlushF`) ������EX�׶Ρ�
// 2. [������] ����ת��: ������������Ҫ�� EX -> EX ת���߼���
//    - `Forward1E`/`Forward2E` ���������2λ����֧�ִӲ�ͬ�׶�ת����
//      (00:��ת��, 01:��MEM/WBת��, 10:��EXת��)
//    - *ע��: ���Ǳ�Ҫ���޸ģ������������ͨ·ֻ֧��1λת���źţ�
//      ���޷�����������������ð�գ���Ҫ�޸�����ͨ·��֧��2λת�����ơ�*
// 3. [������] ת�����ȼ�: ��ȷ��EX->EXת����MEM/WB->EXת�����и��ߵ����ȼ���
// 4. [������] Load-Useð��: �߼�������������ת���߼���ȷ��Эͬ������
//    �����ڲ���Ҫ���������ͣ��
// 5. [��������] `RegWriteE`: Ϊ��ʵ��EX->EXת��������֪��EX�׶ε�ָ���Ƿ�
//    ��д�ؼĴ���������ԭ����ȱʧ�Ĺؼ��źš�
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
    input wire [1:0]  RegReadE,     // ����: ����ID�׶εĶ�ʹ���ź� (RegReadD)
    input wire        RegWriteE,    // **[����/��Ҫ]** EX�׶ε�д��ʹ���ź�
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
    output reg [1:0]  Forward1E,    // **[�޸�/��Ҫ]** �޸�Ϊ2λ��֧�ֶ���ת��Դ
    output reg [1:0]  Forward2E     // **[�޸�/��Ҫ]** �޸�Ϊ2λ��֧�ֶ���ת��Դ
    );

    // --- �������� ---
    // ����ԭ������ `RegReadE` �����ж�ID�׶ε�ָ���Ƿ���Ĵ��������������������
    // Ӧ���� `RegReadD`����������ڴ˼��������ơ�������ź�ȷʵ����EX�׶Σ�
    // ����Ҫ��Ӧ������
    wire load_use_hazard = MemToRegE && (RdE != 5'd0) && 
                           ((RdE == Rs1D && RegReadE[1]) || (RdE == Rs2D && RegReadE[0]));

    always @(*) begin
        // --- Ĭ��ֵ ---
        // ��ÿ�����ڿ�ʼʱ�����ȼ���û��ð�շ���
        StallF  = 1'b0; FlushF  = 1'b0;
        StallD  = 1'b0; FlushD  = 1'b0;
        StallE  = 1'b0; FlushE  = 1'b0;
        StallMW = 1'b0; FlushMW = 1'b0;
        Forward1E = 2'b00; // 00: ��ת��
        Forward2E = 2'b00; // 00: ��ת��

        // --- ��λ�߼� ---
        if (CpuRst) begin
            FlushF = 1'b1; FlushD = 1'b1; FlushE = 1'b1; FlushMW = 1'b1;
        end 
        else begin
            // --- ð�մ����߼� (�����ȼ�����) ---

            // ** 1. ����ð�գ�����/ʹ�� (Load-Use Hazard) **
            // ������ȼ�������ð�ա���EX�׶ε�ָ����LW������Ŀ��Ĵ�����ID�׶�
            // ָ���Դ�Ĵ���ʱ��������ͣ��ˮ��һ�����ڡ�
            if (load_use_hazard) begin
                StallF = 1'b1; // ��ͣPC��IF/ID�Ĵ���
                StallD = 1'b1;
                FlushE = 1'b1; // ��ID/EX�Ĵ����в������� (nop)
            end 
            else begin
                // --- ���û��Load-Use��ͣ������ת���Ϳ���ð�� ---

                // ** 2. ����ð�գ�д��� (RAW) - ת���߼� **

                // ** ���ȼ� 1: EX -> EX ת�� **
                // ����: EX�׶ε�ָ���д�Ĵ���(ALU������)����Ŀ��Ĵ����ǵ�ǰEX�׶�����
                // ��Դ�Ĵ���������������ȼ���ת������ΪEX�׶εĽ����MEM/WB�׶εĸ��¡�
                if (RegWriteE && (RdE != 5'd0)) begin
                    if (RdE == Rs1E) begin
                        Forward1E = 2'b10; // 10: ��EX�׶�ת��
                    end
                    if (RdE == Rs2E) begin
                        Forward2E = 2'b10; // 10: ��EX�׶�ת��
                    end
                end

                // ** ���ȼ� 2: MEM/WB -> EX ת�� **
                // ����: MEM/WB�׶ε�ָ���д�Ĵ�������Ŀ��Ĵ����ǵ�ǰEX�׶������Դ�Ĵ�����
                // ���������û�б��������ȼ��� EX -> EX ת���������
                if (RegWriteMW != 3'b0 && (RdMW != 5'd0)) begin
                    if ((RdMW == Rs1E) && (Forward1E == 2'b00)) begin // ����δ��EX->EXת��ʱ
                        Forward1E = 2'b01; // 01: ��MEM/WB�׶�ת��
                    end
                    if ((RdMW == Rs2E) && (Forward2E == 2'b00)) begin // ����δ��EX->EXת��ʱ
                        Forward2E = 2'b01; // 01: ��MEM/WB�׶�ת��
                    end
                end

                // ** 3. ����ð�� (Control Hazards) **
                // ����: ��֧����ת����ʱ����Ҫ������ˮ�����Ѵ���ȡ���ָ�

                // JAL��ID�׶�ȷ����ת��ַ����Ҫˢ��IF�׶ε�ָ�
                if (JalD) begin
                    FlushF = 1'b1; // [����] ԭΪFlushE���Ǵ���ġ�
                end

                // ��֧��JALR��EX�׶�ȷ����ת����Ҫˢ��IF��ID�����׶ε�ָ�
                if (BranchE || JalrE) begin
                    FlushF = 1'b1;
                    FlushD = 1'b1;
                end
            end
        end
    end

endmodule
