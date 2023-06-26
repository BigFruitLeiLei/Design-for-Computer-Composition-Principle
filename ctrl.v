module ctrl(
   input  [6:0] Op,        // 操作码
   input  [6:0] Funct7,    // funct7
   input  [2:0] Funct3,    // funct3
   input        Zero,
   output       RegWrite,  // 控制信号：寄存器写入
   output       MemWrite,  // 控制信号：内存写入
   output [5:0] EXTOp,     // 控制信号：有符号扩展类型
   output [4:0] ALUOp,     // ALU操作类型
   output [2:0] NPCOp,     // 下一PC操作类型
   output       ALUSrc,    // ALU输入A的选择来源
   output [2:0] DMType,    // 数据存储器类型
   output [1:0] GPRSel,    // 通用寄存器选择
   output [1:0] WDSel      // 写入数据选择
);
   
   // 这段代码实现了对R格式指令的解码，判断指令类型和操作符类型
   wire rtype = ~Op[6] & Op[5] & Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 0110011
   wire i_add = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // add 0000000 000
   wire i_sub = rtype & ~Funct7[6] & Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // sub 0100000 000
   wire i_or  = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & Funct3[1] & ~Funct3[0]; // or 0000000 110
   wire i_and = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & Funct3[1] & Funct3[0]; // and 0000000 111
   wire i_sll = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // sll 0000000 001
   wire i_slt = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // slt 0000000 010
   wire i_sltu = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & Funct3[1] & Funct3[0]; // sltu 0000000 011
   wire i_xor = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // xor 0000000 100
   wire i_srl = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & Funct3[0]; // srl 0000000 101
   wire i_sra = rtype & ~Funct7[6] & Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & Funct3[0]; // sra 0100000 101

   // 这段代码实现了对I类型指令（加载指令）的解码，判断指令类型和操作符类型
   wire itype_l  = ~Op[6] & ~Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 0000011
   wire i_lb = itype_l & ~Funct3[2] & ~Funct3[1] & ~Funct3[0];      // lb   000
   wire i_lh = itype_l & ~Funct3[2] & ~Funct3[1] & Funct3[0];       // lh   001
   wire i_lw = itype_l & ~Funct3[2] & Funct3[1] & ~Funct3[0];       // lw   010
   wire i_lbu = itype_l & Funct3[2] & ~Funct3[1] & ~Funct3[0];      // lbu  100
   wire i_lhu = itype_l & Funct3[2] & ~Funct3[1] & Funct3[0];       // lhu  101
   
   // 这段代码实现了对I类型指令（立即数运算指令）的解码，判断指令类型和操作符类型
   wire itype_r  = ~Op[6] & ~Op[5] & Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 0010011
   wire i_addi = itype_r & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // addi 000
   wire i_ori  = itype_r & Funct3[2] & Funct3[1] & ~Funct3[0];  // ori 110
   wire i_andi = itype_r & Funct3[2] & Funct3[1] & Funct3[0];   // andi 111
   wire i_xori = itype_r & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // xori 100
   wire i_slti = itype_r & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // slti 010
   wire i_sltiu = itype_r & ~Funct3[2] & Funct3[1] & Funct3[0]; // sltiu 011
   wire i_slli = itype_r & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // slli 001
   wire i_srli = itype_r & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & Funct3[0]; // srli 0000000 101
   wire i_srai = itype_r & ~Funct7[6] & Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & Funct3[2] & ~Funct3[1] & Funct3[0]; // srai 0100000 101

   wire i_jalr =Op[6]&Op[5]&~Op[4]&~Op[3]&Op[2]&Op[1]&Op[0];//jalr 1100111
   
   // 这段代码实现了对S类型指令（存储指令）的解码，判断指令类型和操作符类型
   wire stype = ~Op[6] & Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 0100011
   wire i_sw  = stype & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // sw 010
   wire i_sh  = stype & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // sh 001
   wire i_sb  = stype & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // sb 000	

   // 这段代码实现了对SB类型指令（分支指令）的解码，判断指令类型和操作符类型。
   wire sbtype  = Op[6] & Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 1100011
   wire i_beq  = sbtype & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // beq
   wire i_bne  = sbtype & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // bne
   wire i_blt  = sbtype & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // blt
   wire i_bge  = sbtype & Funct3[2] & ~Funct3[1] & Funct3[0]; // bge
   wire i_bltu = sbtype & Funct3[2] & Funct3[1] & ~Funct3[0]; // bltu
   wire i_bgeu = sbtype & Funct3[2] & Funct3[1] & Funct3[0]; // bgeu
   
   // 这段代码实现了对J格式指令的解码，判断指令类型和操作符类型。
   wire i_jal  = Op[6] & Op[5] & ~Op[4] & Op[3] & Op[2] & Op[1] & Op[0];  // jal 1101111
   wire i_auipc = ~Op[6] & ~Op[5] & Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0];
   wire i_lui = ~Op[6] & Op[5] & Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0];

   // 根据指令的类型和操作码确定了控制信号的赋值，这些信号将用于控制处理器中的相应操作，例如寄存器写入、内存写入和ALU操作。
   assign RegWrite   = rtype | itype_l | itype_r | i_jalr | i_jal | i_lui | i_auipc; // 寄存器写入
   assign MemWrite   = stype;                           // 内存写入
   assign ALUSrc     = itype_l | itype_r | stype | i_jal | i_jalr | i_auipc | i_lui;   // ALU输入A的选择来源

   // 有符号扩展类型
   assign EXTOp[5] = i_slli | i_srli | i_srai;
   assign EXTOp[4] = itype_l | i_addi | i_slti | i_sltiu | i_xori | i_ori | i_andi | i_jalr;
   assign EXTOp[3] = stype;
   assign EXTOp[2] = sbtype;
   assign EXTOp[1] = i_auipc | i_lui;
   assign EXTOp[0] = i_jal;

   // 数据存储器类型
   assign DMType[0] = i_lb | i_lh | i_sb | i_sh;
   assign DMType[1] = i_lhu | i_lb | i_sb;
   assign DMType[2] = i_lbu;

   // 写入数据选择
   assign WDSel[0] = itype_l;
   assign WDSel[1] = i_jal | i_jalr;

   // 下一PC操作类型
   assign NPCOp[0] = sbtype & Zero;
   assign NPCOp[1] = i_jal;
   assign NPCOp[2] = i_jalr;

   // ALU操作类型
   assign ALUOp[0] = i_jal | i_jalr | itype_l | stype | i_addi | i_ori | i_add | i_or | i_bne | i_bge | i_bgeu | i_sltiu | i_sltu | i_slli | i_sll | i_sra | i_srai | i_lui;
   assign ALUOp[1] = i_jal | i_jalr | itype_l | stype | i_addi | i_add | i_and | i_andi | i_auipc | i_blt | i_bge | i_slt | i_slti | i_sltiu | i_sltu | i_slli | i_sll;
   assign ALUOp[2] = i_andi | i_and | i_ori | i_or | i_beq | i_sub | i_bne | i_blt | i_bge | i_xor | i_xori | i_sll | i_slli;
   assign ALUOp[3] = i_andi | i_and | i_ori | i_or | i_bltu | i_bgeu | i_slt | i_slti | i_sltiu | i_sltu | i_xor | i_xori | i_sll | i_slli;
   assign ALUOp[4] = i_srl | i_sra | i_srli | i_srai;
endmodule

