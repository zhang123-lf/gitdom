//八位数据的串行发送器，要求参数化奇偶校验部分和停止位数量，假设时钟频率9600hz
module tx #(
    parameter PARITY = "ODD", //ODD奇校验，EVEN偶校验
    parameter STOP_BIT = 1
) (
    input rst ,clk , tx_rdy,    //tx_data和tx_rdy是一起从上层传下来的
    input [7:0] tx_data,        //并行数据tx_data串行tx出去
    output reg tx_ack, tx       //收到数据，需要回复
);
    localparam [3:0]
        IDLE = 0 ,      //空闲位
        START = 1,      //起始位
        FIRST_BIT = 2,  //第一位数据
        SEC_BIT = 3,    //第二位数据
        THIRD_BIT = 4,
        FOUTH_BIT = 5,
        FIF_BIT = 6,
        SIX_BIT = 7,
        SEVN_BIT = 8,
        EIGHT_BIT = 9,
        PAR_BIT = 10,      //奇偶校验位
        STOP1_BIT = 11,     //停止位
        STOP2_BIT = 12;     //停止位

reg [7:0] tx_data_r;  //发送数据的寄存器
wire odd = ^tx_data_r; //得到奇校验的值
reg [3:0] tx_st;        //发送数据的状态

always @(posedge clk  or posedge rst) begin
    if (rst) begin
        tx <= 1'b1;         //复位时或者空闲时，tx发送端发送1
        tx_st <= 0;         //此时状态处于空闲
        tx_data_r <= 0;     //发送数据的寄存器也是空的
        tx_ack <= 1'b0;     //收到数据data，需要回复信号
    end else begin
        case(tx_st)
            IDLE:begin          //空闲状态，未发出信号，tx_ack为0，tx发送端为1
                tx_ack <=1'b0;  
                tx <= 1'b1;
                if (tx_rdy) begin               //tx_rdy表明有数据来了
                    tx_data_r <= tx_data;       //将数据发到tx_data_r寄存器
                    tx_ack <= 1'b1;             //收到tx_dy信号，需要回复一个tx_ack为1的信号
                    tx_st <= START;             //轮到下一个状态
                end
            end
            START:begin
                tx <= 1'b1;
                tx_ack <= 1'b0;
                tx_st <= FIRST_BIT;
            end
            FIRST_BIT:begin
                tx <=tx_data_r[0];
                tx_st <=SEC_BIT;
            end
            SEC_BIT:begin
                tx <=tx_data_r[1];
                tx_st <= THIRD_BIT;
            end
            THIRD_BIT:begin
                tx <=tx_data_r[2];
                tx_st <= FOUTH_BIT;
            end
            FOUTH_BIT:begin
                tx <=tx_data_r[3];
                tx_st <= FIF_BIT;
            end
            FIF_BIT:begin
                tx <=tx_data_r[4];
                tx_st <= SIX_BIT;
            end
            SIX_BIT:begin
                tx <=tx_data_r[5];
                tx_st <= SEVN_BIT;
            end
            SEVN_BIT:begin
                tx <=tx_data_r[6];
                tx_st <= EIGHT_BIT;
            end
            EIGHT_BIT:begin
                tx <=tx_data_r[7];
                if((PARITY =="ODD") ||(PARITY == "EVEN"))
                    tx_st <= PAR_BIT;
                else
                    tx_st <= STOP1_BIT;
            end
            PAR_BIT:begin
                if(PARITY =="ODD")
                    tx <= ~odd;
                else 
                    tx <= odd;
            end
            STOP1_BIT:
            begin
                tx <= 1'b1;
                if (STOP_BIT==1) begin
                    if (tx_rdy) begin
                        tx_data_r <=tx_data;
                        tx_ack <= 1'b1;
                        tx_st <= START;
                    end else begin
                        tx_st <= IDLE;
                    end
                end
                else 
                    tx_st <= STOP2_BIT;
            end
            STOP2_BIT:begin
                tx <= 1'b1;
                if (tx_rdy) begin
                        tx_data_r <=tx_data;
                        tx_ack <= 1'b1;
                        tx_st <= START;
                    end else begin
                        tx_st <= IDLE;
                    end
            end
        endcase
    end
end
endmodule