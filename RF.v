module RF (
  input         clk,         // 时钟输入
  input         rst,         // 复位输入
  input         RFWr,        // 写使能输入
  input  [4:0]  A1, A2, A3,  // 读取地址输入
  input  [31:0] WD,          // 写数据输入
  output [31:0] RD1, RD2     // 读取数据输出
);
  reg [31:0] rf[31:0];        // 寄存器文件

  integer i;                  // 循环计数器

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      // 复位时，将寄存器文件中的所有寄存器值初始化为0
      for (i = 0; i < 32; i = i + 1)
        rf[i] <= 0;            // 初始化为0
    end
    else if (RFWr) begin
      if (A3 != 0) begin
        // 当写使能有效且写入地址不为0时，将写数据写入对应的寄存器
        rf[A3] <= WD;          // 写入数据
      end
    end
  end

  // 根据读取地址，将对应的寄存器值输出
  assign RD1 = (A1 != 0) ? rf[A1] : 0;  // 如果A1不为0，则输出rf[A1]，否则输出0
  assign RD2 = (A2 != 0) ? rf[A2] : 0;  // 如果A2不为0，则输出rf[A2]，否则输出0

endmodule

