`include "ctrl_encode_def.v"

module alu (
  input  signed [31:0] A,     // 输入A，有符号整数
  input  signed [31:0] B,     // 输入B，有符号整数
  input         [4:0]  ALUOp, // ALU操作码
  input  [31:0] PC,           // 程序计数器PC
  output signed [31:0] C,     // ALU计算结果
  output        Zero          // 零标志位，表示计算结果是否为0
);
           
  reg [31:0] C;              // ALU计算结果
  integer i;                 // 循环计数器
       
  always @* begin
    case (ALUOp)
      `ALUOp_nop: C = A;      // 空操作，C = A
      `ALUOp_lui: C = B;      // LUI指令，C = B
      `ALUOp_auipc: C = PC + B;  // AUIPC指令，C = PC + B
      `ALUOp_add: C = A + B;  // 加法，C = A + B
      `ALUOp_sub: C = A - B;  // 减法，C = A - B
      `ALUOp_bne: C = {31'b0, (A == B)};  // BNE指令，C = (A == B) ? 0 : 1
      `ALUOp_blt: C = {31'b0, (A >= B)};  // BLT指令，C = (A >= B) ? 0 : 1
      `ALUOp_bge: C = {31'b0, (A < B)};   // BGE指令，C = (A < B) ? 0 : 1
      `ALUOp_bltu: C = {31'b0, ($unsigned(A) >= $unsigned(B))};  // BLTU指令，C = (A >= B) ? 0 : 1
      `ALUOp_bgeu: C = {31'b0, ($unsigned(A) < $unsigned(B))};   // BGEU指令，C = (A < B) ? 0 : 1
      `ALUOp_slt: C = {31'b0, (A < B)};   // SLT指令，C = (A < B) ? 0 : 1
      `ALUOp_sltu: C = {31'b0, ($unsigned(A) < $unsigned(B))};   // SLTU指令，C = (A < B) ? 0 : 1
      `ALUOp_xor: C = A ^ B;   // 异或操作，C = A ^ B
      `ALUOp_or: C = A | B;    // 或操作，C = A | B
      `ALUOp_and: C = A & B;   // 与操作，C = A & B
      `ALUOp_sll: C = A << B;  // 逻辑左移，C = A << B
      `ALUOp_srl: C = A >> B;  // 逻辑右移，C = A >> B
      `ALUOp_sra: C = A >>> B; // 算术右移，C = A >>> B
    endcase
  end
   
  assign Zero = (C == 32'b0);  // 判断C是否为0，Zero为1表示为0，为0表示不为0

endmodule

    
