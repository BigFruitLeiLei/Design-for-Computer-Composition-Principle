`timescale 1ns / 1ps

module dm_controller(
    input mem_w,
    input [31:0] Addr_in,
    input [31:0] Data_write,
    input [2:0] dm_ctrl,
    input [31:0] Data_read_from_dm,
    output [31:0] Data_read,
    output [31:0] Data_write_to_dm,
    output [3:0] wea_mem
);
    reg [31:0] Data_read_reg;
    reg [31:0] Data_write_to_dm_reg;
    reg [3:0] wea_mem_reg;

    always @(*) begin
        Data_write_to_dm_reg[31:0] <= Data_write[31:0];
        
        if (mem_w) begin
            case (dm_ctrl)
                3'b000: begin // Word 写操作
                    wea_mem_reg = 4'b1111;
                end
                3'b001: begin // Half-word 写操作
                    wea_mem_reg = 4'b0011;
                end
                3'b011: begin // Byte 写操作
                    wea_mem_reg = 4'b0001;
                end
                default: begin // 默认为 Word 写操作
                    wea_mem_reg = 4'b1111;
                end
            endcase
        end 
        else begin
            wea_mem_reg <= 4'b0000;
            
            case (dm_ctrl)
                3'b000: begin // Word 读操作
                    Data_read_reg <= Data_read_from_dm;
                end
                3'b001: begin // Half-word 读操作
                    if (Addr_in[1]) begin
                        Data_read_reg = $signed(Data_read_from_dm[31:16]);
                    end
                    else begin
                        Data_read_reg = $signed(Data_read_from_dm[15:0]);
                    end
                end
                3'b010: begin // Half-word 无符号读操作
                    if (Addr_in[1]) begin
                        Data_read_reg = {16'b0, Data_read_from_dm[31:16]};
                    end
                    else begin
                        Data_read_reg = {16'b0, Data_read_from_dm[15:0]};
                    end
                end
                3'b011: begin // Byte 读操作
                    case (Addr_in[1:0])
                        2'b00: begin
                            Data_read_reg = $signed(Data_read_from_dm[7:0]);
                        end
                        2'b01: begin
                            Data_read_reg = $signed(Data_read_from_dm[15:8]);
                        end
                        2'b10: begin
                            Data_read_reg = $signed(Data_read_from_dm[23:16]);
                        end
                        2'b11: begin
                            Data_read_reg = $signed(Data_read_from_dm[31:24]);
                        end
                    endcase
                end
                3'b100: begin // Byte 无符号读操作
                    case (Addr_in[1:0])
                        2'b00: begin
                            Data_read_reg = {24'b0, Data_read_from_dm[7:0]};
                        end
                        2'b01: begin
                            Data_read_reg = {24'b0, Data_read_from_dm[15:8]};
                        end
                        2'b10: begin
                            Data_read_reg = {24'b0, Data_read_from_dm[23:16]};
                        end
                        2'b11: begin
                            Data_read_reg = {24'b0, Data_read_from_dm[31:24]};
                        end
                    endcase
                end
                default: begin // 默认为 Word 读操作
                    Data_read_reg = Data_read_from_dm;
                end
            endcase
        end
    end
    
    assign Data_write_to_dm = Data_write_to_dm_reg;
    assign Data_read = Data_read_reg;
    assign wea_mem = wea_mem_reg;
    
endmodule