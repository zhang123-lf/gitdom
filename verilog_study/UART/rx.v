module rx #(                         //八倍过采样的参数化RXD接收器，奇偶校验、停止位可以通过参数配置
    parameter PARITY = "ODD",       //'ODD'--odd parity,'EVEN'--even parity, other-- no parity
    parameter STOP_BIT = 1
) (
    input       clk,
    input       rx,
    input       bd8_rate,           //波特率

    output  reg [7:0]   rx_data,      //收到的数据
    output  reg         rx_rdy,       //收到1bit，回应一下，什么时候数据有效
    input               rst
);
    localparam  [3:0]
        IDLE0 = 0 ,      //空闲位
        IDLE1 = 1,
        START = 2,      //起始位
        FIRST_BIT = 3,  //第一位数据
        SEC_BIT = 4,    //第二位数据
        THIRD_BIT = 5,
        FOUTH_BIT = 6,
        FIF_BIT = 7,
        SIX_BIT = 8,
        SEVN_BIT = 9,
        EIGHT_BIT = 10,
        PAR_BIT = 11,      //奇偶校验位
        STOP1_BIT = 12,     //停止位
        STOP2_BIT = 13;     //停止位

    reg [1:0] rx_r;
    reg       rx_dedge;
    reg [7:0] rx_data_tmp;
    reg [1:0] rx_rdy_tmp;
    reg [3:0] sample_st;
    reg [6:0] sample_count;

always @(posedge clk or posedge rst) begin   //获取起始位边沿
    if (rst) begin
        rx_r <= 0;
        rx_dedge <= 0;
    end else begin
        rx_r <= {rx_r[0],rx};
        rx_dedge <= ^rx_r;
    end
end

always @(posedge clk or posedge rst ) begin
    if (rst) begin
        rx_data_tmp <= 0;
        rx_rdy_tmp <= 0;
        sample_st <= 0;
        sample_count <= 0;
    end else begin
        if (bd8_rate) begin
            case (sample_st)
                IDLE0:begin             //等待10bit的rx_r[1]为1
                    rx_rdy_tmp[0] <= 1'b0;   //为了之后和系统时钟同步
                    if (sample_count == 80) begin
                        sample_st <= IDLE1;
                    end else begin
                        if (rx_r[1]) begin
                            sample_count <= sample_count + 1;
                        end
                        else sample_count <= 0;
                    end
                end 
                
                IDLE1:begin                 //等待idle->start_bit的边沿
                    sample_count <= 0;
                    rx_rdy_tmp[0] <= 0;
                    if (rx_dedge) begin
                        sample_st <= START;
                    end
                end

                START:begin                //取start_bit的中心
                    sample_count <= sample_count +1;
                    if (sample_count ==3) begin
                        sample_st <= FIRST_BIT;
                        sample_count <= 0;
                    end 
                end

                FIRST_BIT:begin  //过8个sample_count取第一位
                    sample_count <= sample_count + 1;
                    if (sample_count == 7) begin
                        rx_data_tmp[0] <= rx_r[1];
                        sample_count <= 0;
                        sample_st <= SEC_BIT;
                    end
                end

                SEC_BIT:begin                            //再过8个sample_count取第二位，之后也是如此
                    sample_count <= sample_count + 1;
                    if (sample_count == 7) begin
                        rx_data_tmp[1] <= rx_r[1];
                        sample_count <= 0;
                        sample_st <= THIRD_BIT;
                    end
                end

                THIRD_BIT:begin                            
                    sample_count <= sample_count + 1;
                    if (sample_count == 7) begin
                        rx_data_tmp[2] <= rx_r[1];
                        sample_count <= 0;
                        sample_st <= FOUTH_BIT;
                    end
                end

                FOUTH_BIT:begin                            
                    sample_count <= sample_count + 1;
                    if (sample_count == 7) begin
                        rx_data_tmp[3] <= rx_r[1];
                        sample_count <= 0;
                        sample_st <= FIF_BIT;
                    end
                end

                FIF_BIT:begin                            
                    sample_count <= sample_count + 1;
                    if (sample_count == 7) begin
                        rx_data_tmp[4] <= rx_r[1];
                        sample_count <= 0;
                        sample_st <= SIX_BIT;
                    end
                end

                SIX_BIT:begin                            
                    sample_count <= sample_count + 1;
                    if (sample_count == 7) begin
                        rx_data_tmp[5] <= rx_r[1];
                        sample_count <= 0;
                        sample_st <= SEVN_BIT;
                    end
                end

                SEVN_BIT:begin                            
                    sample_count <= sample_count + 1;
                    if (sample_count == 7) begin
                        rx_data_tmp[6] <= rx_r[1];
                        sample_count <= 0;
                        sample_st <= EIGHT_BIT;
                    end
                end

                EIGHT_BIT:begin                            
                    sample_count <= sample_count + 1;
                    if (sample_count == 7) begin
                        rx_data_tmp[7] <= rx_r[1];
                        sample_count <= 0;
                        if(PARITY == "ODD")
                        sample_st <= PAR_BIT;
                        else 
                        sample_st <= STOP1_BIT;
                    end
                end

                PAR_BIT:begin
                    sample_count <= sample_count + 1;
                    if (sample_count == 7) begin
                        if (^rx_data_tmp != rx_r[1]) begin
                            $display("error");
                        end
                        sample_count <= 0;
                        sample_st <= STOP1_BIT;
                    end
                end

                STOP1_BIT:begin
                    sample_count <= sample_count + 1;
                    rx_rdy_tmp[0] <= 1'b1;
                    if(sample_count ==7)begin
                        sample_count <= 0;
                        if (STOP_BIT ==1) begin
                            sample_st <= IDLE1;
                        end else begin
                            sample_st <= STOP2_BIT;
                        end
                    end
                end

                STOP2_BIT:begin
                    sample_count <= sample_count + 1;
                    rx_rdy_tmp[0] <= 1'b1;
                    if(sample_count ==7)begin
                        sample_count <= 0;
                        sample_st <=IDLE1;
                    end
                end
            endcase
        end
    end                                

end

always @(posedge clk or rst) begin                  //同步系统时钟clk
if (rst) begin
    rx_data <= 0;
    rx_rdy <=0;
end else begin
    rx_rdy_tmp[1] <=rx_rdy_tmp[0];
    if(^rx_rdy_tmp)begin
        rx_data <= rx_data_tmp;
        rx_rdy <= rx_rdy_tmp[1];
    end
end
end
endmodule