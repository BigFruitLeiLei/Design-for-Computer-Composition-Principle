`include "ctrl_encode_def.v"

module EXT (
  input [4:0] iimm_shamt,   // I型指令的移位立即数输入
  input [11:0] iimm,        // I型指令的立即数输入
  input [11:0] simm,        // S型指令的立即数输入
  input [11:0] bimm,        // B型指令的立即数输入
  input [19:0] uimm,        // U型指令的立即数输入
  input [19:0] jimm,        // J型指令的立即数输入
  input [5:0] EXTOp,        // 扩展操作类型输入
  output reg [31:0] immout   // 扩展后的立即数输出
);
   
  always @(*) begin
    case (EXTOp)
      `EXT_CTRL_ITYPE_SHAMT:  // I型指令的移位立即数扩展
        immout <= {27'b0, iimm_shamt[4:0]};
      `EXT_CTRL_ITYPE:        // I型指令的立即数扩展
        immout <= {{20{iimm[11]}}, iimm[11:0]};
      `EXT_CTRL_STYPE:        // S型指令的立即数扩展
        immout <= {{20{simm[11]}}, simm[11:0]};
      `EXT_CTRL_BTYPE:        // B型指令的立即数扩展
        immout <= {{19{bimm[11]}}, bimm[11:0], 1'b0};
      `EXT_CTRL_UTYPE:        // U型指令的立即数扩展
        immout <= {uimm[19:0], 12'b0}; 
      `EXT_CTRL_JTYPE:        // J型指令的立即数扩展
        immout <= {{11{jimm[19]}}, jimm[19:0], 1'b0};
      default:                // 默认情况下，输出全零
        immout <= 32'b0;
    endcase
  end

endmodule
 

