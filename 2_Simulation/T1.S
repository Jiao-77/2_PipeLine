# test_part1.s
# 测试算术、逻辑和立即数指令

# 初始化寄存器
lui x1, 0x12345     # x1 = 0x12345000
addi x2, x0, 0x5    # x2 = 5
#addi x3, x0, 0xFFFF # x3 = 0xFFFFFFFF
lui x3, 0x10
addi x3, x3, -1

# 测试算术指令
add x4, x1, x2      # x4 = x1 + x2 = 0x12345005
sub x5, x1, x2      # x5 = x1 - x2 = 0x12344FFB

# 测试逻辑指令
xor x6, x1, x3      # x6 = x1 ^ x3 = 0xEDCBAFFF
or x7, x1, x3       # x7 = x1 | x3 = 0xFFFFFFFF
and x8, x1, x3      # x8 = x1 & x3 = 0x12345000

# 测试移位指令
slli x9, x1, 4      # x9 = x1 << 4 = 0x23450000
srli x10, x1, 4     # x10 = x1 >> 4 = 0x01234500
srai x11, x1, 4     # x11 = x1 >> 4 (arithmetic) = 0x01234500

# 测试比较指令
slt x12, x2, x3     # x12 = (x2 < x3) ? 1 : 0 = 0 (signed)
sltu x13, x2, x3    # x13 = (x2 < x3) ? 1 : 0 = 1 (unsigned)

# 测试立即数指令
addi x14, x1, 0x10  # x14 = x1 + 0x10 = 0x12345010
slti x15, x2, 0x6   # x15 = (x2 < 6) ? 1 : 0 = 1
sltiu x16, x2, 0x6  # x16 = (x2 < 6) ? 1 : 0 = 1
xori x17, x1, 0xFF  # x17 = x1 ^ 0xFF = 0x12345FFF
ori x18, x1, 0xFF   # x18 = x1 | 0xFF = 0x12345FFF
andi x19, x1, 0xFF  # x19 = x1 & 0xFF = 0x00000000

# 测试 LUI 和 AUIPC
lui x20, 0xABCDE    # x20 = 0xABCDE000
auipc x21, 0x1      # x21 = PC + (1 << 12) = PC + 0x1000

# 结束测试
addi x0, x0, 0      # NOP，结束
