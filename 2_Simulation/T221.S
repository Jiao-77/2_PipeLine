# RISC-V汇编测试代码
# 测试指令: JALR, LB, LH, LW, LBU, LHU, SB, SH, SW, BEQ, BNE, BLT, BLTU, BGE, BGEU, JAL

.section .text
.global _start

_start:
    # 初始化寄存器
    lui x1, 0x10          # 设置基地址
    lui x2, 0x8      # 测试数据
    lui x3, 0x1      # 测试数据
    lui x4, 0x0             # 计数器
    lui x5, 0x5A      # 测试模式
    lui x6, 0x10        
    lui x7, 0x8      
    
    # 存储指令测试
    sw x2, 0(x1)          # 存储字
    lui x3, 0x1     
    lui x4, 0x0            
    lui x5, 0x5A     
    lui x6, 0x10       
    lui x7, 0x8  

    sh x2, 4(x1)          # 存储半字
      lui x3, 0x1
    lui x4, 0x0
    lui x5, 0x5A
    lui x10, 0x10
    lui x7, 0x8
    sb x2, 6(x1)          # 存储字节
    
    # 加载指令测试
    lw x6, 0(x1)          # 加载字
    lh x7, 4(x1)          # 加载半字(有符号)
    lb x8, 6(x1)          # 加载字节(有符号)
    lhu x9, 4(x1)         # 加载半字(无符号)
    lbu x10, 6(x1)        # 加载字节(无符号)
    

