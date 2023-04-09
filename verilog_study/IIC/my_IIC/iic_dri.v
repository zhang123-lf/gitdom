`timescale 10ps/1ps
module iic_dri #(
    parameter   SYS_CLK_F = 10000_0000,          //系统时钟的输入频率
    parameter   IIC_F     = 10000                //scl的输出频率
) (
    input       sys_clk,
    input       rst,            //系统复位（全局复位）
    output      o_scl,

    input       [6:0] dev_addr,         //从机设备地址
    input       [7:0] word_addr,        //从机设备寄存器地址
    input       [7:0] data,             //读入的数据
    input             wr_control,       //读写控制位


    output      reg  [7:0]   o_data,
    output      reg     one_done_flag,
    inout       sda
);
///////////////////////////////////////////////////////////////////////////////////////////////
    localparam  C_DIV = SYS_CLK_F/IIC_F;     //获得scl需要的分频系数
    localparam  C_DIV_0 = (C_DIV >> 1)-1,       // 1/2的SCL周期时长 
                C_DIV_1 = (C_DIV >> 2)-1,      // 1/4的SCL周期时长 高电平中间标志位
                C_DIV_2 = (C_DIV_0 + C_DIV_1) + 1,      // 3/4的SCL周期时长 低电平中间标志位
                C_DIV_3 = (C_DIV >>1) +1;               //产生SCL下降沿标志位

reg     [9:0]     clk_cnt;              //分频计数
wire         scl_high_mid;              //scl高电平中间位
wire          scl_low_mid;              //scl低电平中间位
wire              scl_neg;              //scl下降沿标志位
reg                scl_en;       

always @(posedge sys_clk or rst) begin
    if (rst) begin
        clk_cnt <= 10'b0;
    end else begin if(scl_en)
        if (clk_cnt == C_DIV - 1'b1) begin
            clk_cnt <= 10'b0;                                                       //这一块产生SCL和其他一些标志位
        end else begin
            clk_cnt <= clk_cnt + 1'b1;
        end
        else clk_cnt <= 10'b0; 
    end
end

assign o_scl = (clk_cnt <= C_DIV_0)? 1'b1:1'b0;
assign scl_high_mid = (clk_cnt == C_DIV_1)? 1'b1:1'b0;
assign scl_low_mid = (clk_cnt == C_DIV_2)? 1'b1:1'b0;
assign scl_neg = (clk_cnt == C_DIV_3)? 1'b1:1'b0;
////////////////////////////////////////////////////////////////////////////////////////////////////////

reg         sda_mode; //1为输出。0为输入
reg       sda_out_r; //sda作为输出的寄存器
wire          sda_in; //sda作为输入

assign sda =(sda_mode == 1'b1)?sda_out_r:1'bz;
assign sda_in =sda;


reg [7:0] data_r;
reg [3:0] bit_cnt;
reg           ack;
reg [3:0] state;
reg [3:0] state1;
always @(posedge sys_clk or rst) begin
    if (rst) begin
        sda_out_r <= 1'b1;
        sda_mode <= 1'b1;
        bit_cnt <= 4'b0;
        data_r <= 8'b0;
        state <= 4'd0;
        state1 <= 4'd0;
        one_done_flag <= 0;
    end else begin
            case (state)
                4'd0: begin        //空闲状态
                sda_out_r <= 1'b1;
                sda_mode <= 1'b1;
                bit_cnt <= 4'b0;
                data_r <= 8'b0;
                state <= 4'd1;
                state1 <= 4'd0;
                one_done_flag <= 0;
                end

                4'd1:begin              //加载从机地址，传输的数据
                    if (state1==0) begin
                        data_r <={dev_addr,1'b0};
                        state <=4'd2;
                    end else if(state1==4'd1) begin
                        data_r <=data;
                        state <= 4'd3;
                    end else if (state1==4'd2) begin
                        data_r <= word_addr;
                        state <= 4'd3;
                    end
                    
                end

                4'd2:begin              //发送起始信号
                sda_mode <= 1'b1;
                scl_en <= 1'b1;
                if (scl_high_mid) begin
                    sda_out_r <= 1'b0;
                    state <= 4'd3;
                end else state <= 4'd2;             //在这一状态等待
                
                end

                4'd3:begin              //输出从机地址+读写位
                    sda_mode <= 1'b1;
                    scl_en <= 1'b1;
                    bit_cnt <= 4'b0;
                    if (scl_low_mid) begin
                        sda_out_r <= data_r[bit_cnt];
                        bit_cnt <= bit_cnt + 1;
                        if (bit_cnt <= 4'd7) begin
                            state <= 4'd3;
                        end else begin
                            bit_cnt <= 4'b0;
                            state <=4'd4;
                        end
                    end  else state <=4'd3;
                end

                4'd4:begin              //获得应答位
                    sda_mode <= 1'b0;
                    scl_en <= 1'b1;
                    if (scl_high_mid) begin
                        ack <= sda_in;
                        state <= 4'd5;
                    end else state <=4'd4;
                end 

                4'd5:begin
                    if (ack) begin
                        case (state1)
                            4'd0: begin
                                if (wr_control) begin
                                    state1 <= 4'd1;       //写
                                end else begin
                                    state1 <=4'd2;          //读
                                end
                                state <= 4'd1;
                            end
                            4'd1:begin
                                scl_en <= 1'b1;
                                sda_mode <=1'b1;
                                if (scl_neg) begin
                                    sda_out_r <= 1'b0;
                                end else begin
                                    state <=4'd5;
                                end
                                state <= 4'd6;
                            end
                            4'd2:begin
                                state <= 4'd7;
                                state1 <= 4'd3;
                            end 
                            default:state <=4'd5;
                        endcase
                        
                        
                    end else begin
                        if (state1==0 || state1==2) begin
                            state <= 4'd0;
                        end else begin 
                                state <= 4'd6;
                                scl_en <= 1'b1;
                                sda_mode <=1'b1;
                                if (scl_neg) begin
                                    sda_out_r <= 1'b0;
                                end else begin
                                    state <=4'd5;
                                end
                            end
                        end
                    end

                4'd6:begin                      //停止位
                    sda_mode <= 1'b1;
                    scl_en <= 1'b1;
                    if (scl_high_mid) begin
                        sda_out_r <= 1'b1;
                        one_done_flag <= 1'b1;
                        state <= 1'b0;
                    end else begin
                        state <= 4'd6;
                    end
                end
                4'd7:begin
                    sda_mode <= 1'b0;
                    scl_en <= 1'b1;
                    if (scl_high_mid) begin
                        o_data[bit_cnt] <= sda_in;
                        if (bit_cnt >= 4'd7) begin
                            bit_cnt <= 4'd0;
                            state <= 4'd6;
                        end else begin
                            bit_cnt <=bit_cnt + 1'b1;
                            state <=4'd7;
                        end
                    end else begin
                        state <= 4'd7;
                    end
                end
            endcase
        end
    end

endmodule