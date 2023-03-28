module rx_sb (          //中心对齐，就采集一个start_bit的中间信号
    input clk,
    input rst,
    input rx,
    input bd8_rate,

    output reg rx_bit,
    output reg rx_bit_rdy       //回应
);
    reg [1:0] rx_r;         //寄存器，可以给边沿检测
    reg       rx_dedge ;   //边沿检测信号
    reg [2:0] sample_st;        //状态机
    reg [6:0] sample_count;     //计数

always @(posedge clk or posedge rst) begin   //边沿检测电路
    if (rst) begin
        rx_r <= 0;
        rx_dedge <= 0;
    end else begin
        if (bd8_rate) begin
            rx_r <={rx_r[0],rx};
            rx_dedge <= ^rx_r;              //双边沿，因为检测start_bit，从1-》0,双边沿或者下降沿也可以
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        sample_st <= 0;
        sample_count <=0;
        rx_bit <= 1'b1;
        rx_bit_rdy <=1'b0;
    end else 
        case(sample_st)
        0:begin
            if (sample_count == 12) begin //空闲位，假设10bit的空闲位（1）
                sample_st<= 1;
            end else begin
                if (bd8_rate) begin
                    if (rx_r[1]) begin
                        sample_count <= sample_count + 1;
                    end else begin
                        sample_count <= 0;
                    end
                end
            end
        end

        1:begin                         //等待start_bit
            sample_count <= 0;
            if(rx_dedge)
                sample_st <=2;
        end

        2:begin                         //取start_bit中间位置 4/8
            if (sample_count == 4) begin
                rx_bit <= rx_r[1];
                rx_bit_rdy <= 1'b1;
                sample_st <= 3;
            end else if (bd8_rate) begin
                sample_count <= sample_count + 1;
            end
        end

        3:begin
            sample_st <= 3;
        end
        endcase
end
endmodule