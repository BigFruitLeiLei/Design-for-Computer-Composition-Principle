`timescale 1ns / 1ps

module top(
  input rstn,                   // 异步复位信号
  input [4:0] btn_i,            // 按钮输入
  input [15:0] sw_i,            // 开关输入
  input clk,                    // 时钟输入
  
  output [7:0] disp_an_o,       // 数码管段选输出
  
  output [7:0] disp_seg_o,      // 数码管段码输出
  output [15:0] led_o           // LED输出
);

  wire [31:0] pc;               // 程序计数器输出
  wire [31:0] inst_in;          // 指令输入
  wire [31:0] data_in;          // 数据输入
  wire [31:0] addr_in;          // 地址输入
  wire [2:0] dm_ctrl;           // 数据存储控制信号
  wire [31:0] data1;            // 数据1
  wire [31:0] Dout;             // 数据输出
  wire [31:0] clkdiv;           // 时钟分频器输出
  assign data1 = {2'b0, pc[31:2]};     // 数据1为程序计数器的高30位
  wire [63:0] point_in;         // 小数点输入
  assign point_in = {clkdiv[31:0], clkdiv[31:0]};    // 小数点输入为时钟分频器输出的高32位
  
  wire clk0;                    // 分频后的时钟0
  wire clk1;                    // 分频后的时钟1
  wire clk2;                    // 分频后的时钟2
  wire flash;                   // 闪烁信号
  
  assign clk0 = clkdiv[6];       // 分频后的时钟0为时钟分频器的第7位
  assign clk1 = clkdiv[9];       // 分频后的时钟1为时钟分频器的第10位
  assign clk2 = clkdiv[11];      // 分频后的时钟2为时钟分频器的第12位
  assign flash = clkdiv[10];     // 闪烁信号为时钟分频器的第11位
  
  SCPU U1_SCPU(
    .clk(clkk),
    .reset(rst_i),
    //.MIO_ready(cpumio),
    .inst_in(inst_in),
    .Data_in(data_in),
    .mem_w(mw),
    .PC_out(pc),
    .Addr_out(addr_in),
    .Data_out(Dout),
    .DMRType(dm_ctrl)
    //.CPU_MIO(cpumio),
    //.INT(c0o)
  ); 
  
  wire [15:0] sw_out;           // 开关输出
  wire sw2;                     // 开关2
  wire sw0;                     // 开关0
  wire [2:0] switch;            // 开关状态
  
  assign sw2 = sw_out[2];       // 开关2为开关输出的第3位
  assign switch = sw_out[7:5];  // 开关状态为开关输出的第8到10位
  assign sw0 = sw_out[0];       // 开关0为开关输出的第1位
  
  ROM_D U2_ROMD(
    .a(pc[11:2]),
    .spo(inst_in)
  );
  
  wire [31:0] data_write;       // 数据写入
  wire [31:0] drfd;             // 数据读取器数据输出
  wire [31:0] douta;            // RAM_B数据输出
  wire [31:0] dwtd;             // RAM_B数据写入
  wire [3:0] wea;               // RAM_B写使能
  
  dm_controller U3_dm_controller(
    .mem_w(mw),
    .Addr_in(addr_in),
    .Data_write(data_write),
    .dm_ctrl(dm_ctrl),
    .Data_read_from_dm(drfd),
    .Data_read(data_in),
    .Data_write_to_dm(dwtd),
    .wea_mem(wea)
  );
  
  assign clka = ~clk;           // 取时钟的反相作为clka信号
  
  wire [9:0] rama;              // RAM_B地址
  RAM_B U4_RAM_B(
    .addra(rama),
    .clka(clka),
    .dina(dwtd),
    .wea(wea),
    .douta(douta)
  );
  
  wire [4:0] btnout;            // 按钮输出
  wire [15:0] ledout;           // LED输出
  wire [31:0] data3;            // 数据3
  
  wire [31:0] data0;            // 数据0
  wire [15:0] SWW;              // 开关输出（低16位）
  
  assign SWW = sw_out[15:0];    // SWW为开关输出的低16位
  MIO_BUS U4_MIO_BUS(
    .clk(clk),
    .rst(rst_i),
    .BTN(btnout),
    .SW(SWW),
    .mem_w(mw),
    .Cpu_data2bus(Dout),
    .addr_bus(addr_in),
    .ram_data_out(douta),
    .led_out(ledout),
    .counter_out(data3),
    .counter0_out(c0o),
    .counter1_out(c1o),
    .counter2_out(c2o),
    .Cpu_data4bus(drfd),
    .ram_data_in(data_write),
    .ram_addr(rama),
    .data_ram_we(),
    .GPIOf0000000_we(GPIOf),
    .GPIOe0000000_we(GPIOe),
    .counter_we(counterwe),
    .Peripheral_in(data0)
  );
  
  wire [31:0] dispn;            // 数码管显示数值
  wire [7:0] pout;              // 数码管小数点输出
  wire [7:0] leo;               // 时钟分频器输出
  
  wire [63:0] les;              // 数码管使能信号
  assign les = {64{1'b1}};      // les为全1的64位信号
  
  Multi_8CH32 U5_Multi_8CH32(
    .clk(IO_clk_i),
    .rst(rst_i),
    .EN(GPIOe),
    .Switch(switch),
    .point_in(point_in),
    .LES(les),
    .data0(data0),
    .data1(data1),
    .data2(inst_in),
    .data3(data3),
    .data4(addr_in),
    .data5(Dout),
    .data6(drfd),
    .data7(pc),
    .point_out(pout),
    .LE_out(leo),
    .Disp_num(dispn)
  );
  
  SSeg7 U6_SSeg7(
    .clk(clk),
    .rst(rst_i),
    .SW0(sw0),
    .flash(flash),
    .Hexs(dispn),
    .point(pout),
    .LES(leo),
    .seg_an(disp_an_o),
    .seg_sout(disp_seg_o)
  );
  
  wire [1:0] cs;                // 计数器使能信号
  
  SPIO U7_SPIO(
    .clk(IO_clk_i),
    .rst(rst_i),
    .EN(GPIOf),
    .P_Data(data0),
    .counter_set(cs),
    .LED_out(ledout),
    .led(led_o[15:0])
  );
  
  clk_div U8_clk_div(
    .clk(clk),
    .SW2(sw2),
    .rst(rst_i),
    .clkdiv(clkdiv[31:0]),
    .Clk_CPU(clkk)
  );
  
  assign IO_clk_i = ~clkk;      // 取clkk的反相作为IO_clk_i信号
  assign rst_i = ~rstn;         // 取rstn的反相作为rst_i信号
  
  Counter_x U9_Counter_x(
    .rst(rst_i),
    .clk(IO_clk_i),
    .clk0(clk0),
    .clk1(clk1),
    .clk2(clk2),
    .counter_we(counterwe),
    .counter_val(data0),
    .counter_ch(cs),
    .counter0_OUT(c0o),
    .counter1_OUT(c1o),
    .counter2_OUT(c2o),
    .counter_out()
  );
  
  Enter U10_Enter(
    .clk(clk),
    .BTN(btn_i),
    .SW(sw_i),
    .BTN_out(btnout),
    .SW_out(sw_out[15:0])  
  );
  
endmodule
