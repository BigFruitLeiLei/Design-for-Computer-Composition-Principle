`include "ctrl_encode_def.v"

module SCPU (
    input clk,               // 时钟信号
    input reset,             // 复位信号
    input [31:0] inst_in,    // 输入的指令
    input [31:0] Data_in,    // 数据存储器的输入数据

    output mem_w,            // 内存写入信号
    output [31:0] PC_out,    // PC 地址输出
    output [31:0] Addr_out,  // ALU 输出地址
    output [31:0] Data_out,  // 数据存储器的输出数据

    input [4:0] reg_sel,     // 寄存器选择（用于调试）
    output [31:0] reg_data,  // 选定寄存器的数据（用于调试）
    output [2:0] DMType      // 数据存储器类型
);
    wire RegWrite;           // 寄存器写入控制信号
    wire [5:0] EXTOp;        // 有符号扩展控制信号
    wire [4:0] ALUOp;        // ALU 操作类型
    wire [2:0] NPCOp;        // 下一个 PC 操作类型
    wire [1:0] WDSel;        // 写入数据选择
    wire [1:0] GPRSel;       // 通用寄存器选择
    wire ALUSrc;             // ALU 输入 A 的选择信号
    wire Zero;               // ALU 输出是否为零
    wire [31:0] NPC;         // 下一个 PC 地址
    wire [4:0] rs1;          // rs1
    wire [4:0] rs2;          // rs2
    wire [4:0] rd;           // rd
    wire [6:0] Op;           // 指令操作码
    wire [6:0] Funct7;       // funct7
    wire [2:0] Funct3;       // funct3
    wire [11:0] Imm12;       // 12 位立即数
    wire [31:0] Imm32;       // 32 位立即数
    wire [19:0] IMM;         // 20 位立即数（地址）
    wire [4:0] A3;           // 写入寄存器地址
    reg [31:0] WD;           // 写入寄存器的数据
    wire [31:0] RD1, RD2;    // rs1 和 rs2 寄存器的数据
    wire [31:0] B;           // ALU 输入 B

    // 下面这段声明了一些 wire 类型的信号，用于存储不同类型的立即数和 ALU 的输出结果
    wire [4:0] iimm_shamt;   // i 类型指令的立即数中的位移量
    wire [11:0] iimm, simm, bimm;   // i、s、b 类型指令的立即数
    wire [19:0] uimm, jimm;   // u、j 类型指令的立即数
    wire [31:0] immout;   // 最终选择的立即数
    wire [31:0] aluout;   // ALU 的输出结果

    
    assign Addr_out = aluout;      
    // 将 ALU 输出赋值给 Addr_out
    assign B = (ALUSrc) ? immout : RD2;
    // 如果 ALUSrc 为真，将 immout 赋值给 B，否则将 RD2 赋值给 B
    assign Data_out = RD2;
    // 将 RD2 赋值给 Data_out

    assign iimm_shamt = inst_in[24:20];
    // 从指令中提取位于索引 24 到 20 的字段，赋值给 iimm_shamt
    assign iimm = inst_in[31:20];
    // 从指令中提取位于索引 31 到 20 的字段，赋值给 iimm
    assign simm = {inst_in[31:25], inst_in[11:7]};
    // 从指令中提取位于索引 31 到 25 和 11 到 7 的字段，拼接为 simm
    assign bimm = {inst_in[31], inst_in[7], inst_in[30:25], inst_in[11:8]};
    // 从指令中提取位于索引 31、7、30 到 25 和 11 到 8 的字段，拼接为 bimm
    assign uimm = inst_in[31:12];
    // 从指令中提取位于索引 31 到 12 的字段，赋值给 uimm
    assign jimm = {inst_in[31], inst_in[19:12], inst_in[20], inst_in[30:21]};
    // 从指令中提取位于索引 31、19 到 12、20 和 30 到 21 的字段，拼接为 jimm

    assign Op = inst_in[6:0];
    // 从指令中提取位于索引 6 到 0 的字段，赋值给 Op
    assign Funct7 = inst_in[31:25];
    // 从指令中提取位于索引 31 到 25 的字段，赋值给 Funct7
    assign Funct3 = inst_in[14:12];
    // 从指令中提取位于索引 14 到 12 的字段，赋值给 Funct3
    assign rs1 = inst_in[19:15];
    // 从指令中提取位于索引 19 到 15 的字段，赋值给 rs1
    assign rs2 = inst_in[24:20];
    // 从指令中提取位于索引 24 到 20 的字段，赋值给 rs2
    assign rd = inst_in[11:7];
    // 从指令中提取位于索引 11 到 7 的字段，赋值给 rd
    assign Imm12 = inst_in[31:20];
    // 从指令中提取位于索引 31 到 20 的字段，赋值给 Imm12
    assign IMM = inst_in[31:12];
    // 从指令中提取位于索引 31 到 12 的字段，赋值给 IMM

   
    // 实例化控制单元
    ctrl U_ctrl (
        .Op(Op),
        .Funct7(Funct7),
        .Funct3(Funct3),
        .Zero(Zero),
        .RegWrite(RegWrite),
        .MemWrite(mem_w),
        .EXTOp(EXTOp),
        .ALUOp(ALUOp),
        .NPCOp(NPCOp),
        .ALUSrc(ALUSrc),
        .GPRSel(GPRSel),
        .WDSel(WDSel),
        .DMType(DMType)
    );

    // 实例化 PC 单元
    PC U_PC (
        .clk(clk),
        .rst(reset),
        .NPC(NPC),
        .PC(PC_out)
    );

    // 实例化 NPC 单元
    NPC U_NPC (
        .PC(PC_out),
        .NPCOp(NPCOp),
        .IMM(immout),
        .NPC(NPC),
        .aluout(aluout)
    );

    // 实例化扩展单元
    EXT U_EXT (
        .iimm_shamt(iimm_shamt),
        .iimm(iimm),
        .simm(simm),
        .bimm(bimm),
        .uimm(uimm),
        .jimm(jimm),
        .EXTOp(EXTOp),
        .immout(immout)
    );

    // 实例化寄存器文件单元
    RF U_RF (
        .clk(clk),
        .rst(reset),
        .RFWr(RegWrite),
        .A1(rs1),
        .A2(rs2),
        .A3(rd),
        .WD(WD),
        .RD1(RD1),
        .RD2(RD2)
    );

    // 实例化 ALU 单元
    alu U_alu (
        .A(RD1),
        .B(B),
        .ALUOp(ALUOp),
        .C(aluout),
        .Zero(Zero),
        .PC(PC_out)
    );

// 这段代码根据 WDSel 的值选择性地将数据赋值给 WD
always @* begin
    case (WDSel)
        `WDSel_FromALU: WD <= aluout;             // 如果 WDSel 为 `WDSel_FromALU，则将 aluout 赋值给 WD
        `WDSel_FromMEM: WD <= Data_in;            // 如果 WDSel 为 `WDSel_FromMEM，则将 Data_in 赋值给 WD
        `WDSel_FromPC: WD <= PC_out + 4;          // 如果 WDSel 为 `WDSel_FromPC，则将 PC_out 加 4 后赋值给 WD
    endcase
end

endmodule
