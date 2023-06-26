`include "ctrl_encode_def.v"

module NPC (
  input  [31:0] PC,        // 当前PC
  input  [2:0]  NPCOp,     // 下一PC操作码
  input  [31:0] IMM,       // 立即数
  input  [31:0] aluout,   // ALU计算结果
  output reg [31:0] NPC   // 下一PC
);
   
  wire [31:0] PCPLUS4;     // PC + 4
   
  assign PCPLUS4 = PC + 4; // 计算 PC + 4
   
  always @* begin
    case (NPCOp)
      `NPC_PLUS4:  begin  // 下一PC为 PC + 4
        NPC = PCPLUS4;
      end
      `NPC_BRANCH: begin  // 下一PC为 PC + IMM (分支跳转)
        NPC = PC + IMM;
      end
      `NPC_JUMP:   begin  // 下一PC为 PC + IMM (跳转指令)
        NPC = PC + IMM;
      end
      `NPC_JALR:   begin  // 下一PC为 ALU计算结果 (JALR指令)
        NPC = aluout;
      end
      default:     begin  // 默认情况下，下一PC为 PC + 4
        NPC = PCPLUS4;
      end
    endcase
  end

endmodule

