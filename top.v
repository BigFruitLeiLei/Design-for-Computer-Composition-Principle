`timescale 1ns / 1ps

module top (
  input rstn,
  input [4:0] btn_i,
  input [15:0] sw_i,
  input clk,
  output [7:0] disp_an_o,
  output [7:0] disp_seg_o,
  output [15:0] led_o
);

  // 信号声明
  wire [31:0] pc;
  wire [31:0] inst_in;
  wire [31:0] data_in;
  wire [31:0] addr_in;
  wire [2:0] dm_ctrl;
  wire [31:0] data1;
  wire [31:0] Dout;
  wire [31:0] clkdiv;
  wire [63:0] point_in;
  wire clk0, clk1, clk2, flash;
  wire [15:0] sw_out;
  wire sw2, sw0;
  wire [2:0] switch;
  wire [4:0] btnout;
  wire [15:0] ledout;
  wire [31:0] data3;
  wire [31:0] data0;
  wire [15:0] SWW;
  wire [7:0] pout;
  wire [7:0] leo;
  wire [31:0] dispn;
  wire [1:0] cs;


  // Wire Assignments
  assign btnout = btn_i;
  assign ledout = led_o[15:0];
  assign point_in = {32'b0, clkdiv[31:0]};
  assign clka = ~clk;
  assign IO_clk_i = ~clkk;
  assign rst_i = ~rstn;


  // 组件实例化
  SCPU U1_SCPU (
    .clk(clkk),
    .reset(rst_i),
    .MIO_ready(cpumio),
    .inst_in(inst_in),
    .Data_in(data_in),
    .mem_w(mw),
    .PC_out(pc),
    .Addr_out(addr_in),
    .Data_out(Dout),
    .DMType(dm_ctrl),
    .CPU_MIO(cpumio),
    .INT(c0o)
  );

  ROM_D U2_ROMD (
    .a(pc[11:2]),
    .spo(inst_in)
  );

  dm_controller U3_dm_controller (
    .mem_w(mw),
    .Addr_in(addr_in),
    .Data_write(data_write),
    .dm_ctrl(dm_ctrl),
    .Data_read_from_dm(drfd),
    .Data_read(data_in),
    .Data_write_to_dm(dwtd),
    .wea_mem(wea)
  );

  RAM_B U4_RAM_B (
    .addra(rama),
    .clka(clka),
    .dina(dwtd),
    .wea(wea),
    .douta(douta)
  );

  MIO_BUS U4_MIO_BUS (
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

  Multi_8CH32 U5_Multi_8CH32 (
    .clk(IO_clk_i),
    .rst(rst_i),
    .EN(GPIOe),
    .Switch(switch),
    .point_in(point_in),
    .LES({64{1'b1}}),
    .data0(data0),
    .data1({2'b0, pc[31:2]}),
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

  SSeg7 U6_SSeg7 (
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

  SPIO U7_SPIO (
    .clk(IO_clk_i),
    .rst(rst_i),
    .EN(GPIOf),
    .P_Data(data0),
    .counter_set(cs),
    .LED_out(ledout),
    .led(led_o[15:0])
  );

  clk_div U8_clk_div (
    .clk(clk),
    .SW2(sw2),
    .rst(rst_i),
    .clkdiv(clkdiv[31:0]),
    .Clk_CPU(clkk)
  );

  Counter_x U9_Counter_x (
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

  Enter U10_Enter (
    .clk(clk),
    .BTN(btn_i),
    .SW(sw_i),
    .BTN_out(btnout),
    .SW_out(sw_out[15:0])  
  );


endmodule

