module PC (
  input              clk,      // 时钟输入
  input              rst,      // 复位输入
  input       [31:0] NPC,      // 下一指令地址输入
  output reg  [31:0] PC        // 当前指令地址输出
);
   
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      // 复位时，将PC重置为全零
      PC <= 32'h0000_0000;     // 初始化PC为32位全零
    end
    else begin
      // 在上升沿时更新PC为下一指令地址
      PC <= NPC;               // 将PC更新为下一指令地址
    end
  end

endmodule


