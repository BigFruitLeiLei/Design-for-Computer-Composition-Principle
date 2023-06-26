// NPC控制信号
`define NPC_PLUS4           3'b000   // 下一PC为 PC + 4
`define NPC_BRANCH          3'b001   // 下一PC为 PC + IMM (分支跳转)
`define NPC_JUMP            3'b010   // 下一PC为 PC + IMM (跳转指令)
`define NPC_JALR            3'b100   // 下一PC为 ALU计算结果 (JALR指令)

// ALU控制信号
`define ALU_NOP             3'b000   // 无操作
`define ALU_ADD             3'b001   // 加法
`define ALU_SUB             3'b010   // 减法
`define ALU_AND             3'b011   // 与操作
`define ALU_OR              3'b100   // 或操作

// 扩展控制信号（itype, stype, btype, utype, jtype）
`define EXT_CTRL_ITYPE_SHAMT 6'b100000   // I型指令，立即数为shamt
`define EXT_CTRL_ITYPE      6'b010000   // I型指令
`define EXT_CTRL_STYPE      6'b001000   // S型指令
`define EXT_CTRL_BTYPE      6'b000100   // B型指令
`define EXT_CTRL_UTYPE      6'b000010   // U型指令
`define EXT_CTRL_JTYPE      6'b000001   // J型指令

// GPR选择信号
`define GPRSel_RD           2'b00   // 目标寄存器选择为RD
`define GPRSel_RT           2'b01   // 目标寄存器选择为RT
`define GPRSel_31           2'b10   // 目标寄存器选择为R31

// WD选择信号
`define WDSel_FromALU       2'b00   // 数据写入来自ALU计算结果
`define WDSel_FromMEM       2'b01   // 数据写入来自内存读取结果
`define WDSel_FromPC        2'b10   // 数据写入来自PC

// ALU操作码
`define ALUOp_nop           5'b00000   // 无操作
`define ALUOp_lui           5'b00001   // LUI指令
`define ALUOp_auipc         5'b00010   // AUIPC指令
`define ALUOp_add           5'b00011   // 加法
`define ALUOp_sub           5'b00100   // 减法
`define ALUOp_bne           5'b00101   // 不等于比较
`define ALUOp_blt           5'b00110   // 小于比较
`define ALUOp_bge           5'b00111   // 大于等于比较
`define ALUOp_bltu          5'b01000   // 无符号小于比较
`define ALUOp_bgeu          5'b01001   // 无符号大于等于比较
`define ALUOp_slt           5'b01010   // 有符号小于比较
`define ALUOp_sltu          5'b01011   // 无符号小于比较
`define ALUOp_xor           5'b01100   // 异或操作
`define ALUOp_or            5'b01101   // 或操作
`define ALUOp_and           5'b01110   // 与操作
`define ALUOp_sll           5'b01111   // 逻辑左移
`define ALUOp_srl           5'b10000   // 逻辑右移
`define ALUOp_sra           5'b10001   // 算术右移

// 数据访问类型
`define dm_word             3'b000   // 字
`define dm_halfword         3'b001   // 半字
`define dm_halfword_unsigned 3'b010   // 无符号半字
`define dm_byte             3'b011   // 字节
`define dm_byte_unsigned    3'b100   // 无符号字节


