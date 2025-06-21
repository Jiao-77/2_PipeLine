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
    
    # 分支指令测试
    beq x6, x2, branch_ok1 # 相等分支
    j test_fail
    
branch_ok1:
    bne x6, x3, branch_ok2 # 不等分支
    j test_fail
    
branch_ok2:
    blt x4, x1, branch_ok3 # 小于(有符号)
    j test_fail
    
branch_ok3:
    bltu x4, x1, branch_ok4 # 小于(无符号)
    j test_fail
    
branch_ok4:
   addi x4, x4, -1
    bge x1, x4, branch_ok5 # 大于等于(有符号)
    j test_fail
    
branch_ok5:
    lui x4, 0xFF
    bgeu x1, x4, branch_ok6 # 大于等于(无符号)
    j test_fail
    
branch_ok6:
    # JAL和JALR测试
    jal x11, func_test     # 跳转并链接
    
    # JALR测试
    la x12, func_test2
    jalr x13, x12, 0
    
    # 测试通过
    lui a0, 0               # 退出状态0
    lui a7, 93              # 退出系统调用号
    ecall
    
test_fail:
    lui a0, 1               # 退出状态1
    lui a7, 93              # 退出系统调用号
    ecall
    
func_test:
    # 简单函数测试
    addi x5, x5, 1
    jalr x0, x11, 0        # 返回
    
func_test2:
    # 另一个函数测试
    xor x5, x5, x2
    ret
