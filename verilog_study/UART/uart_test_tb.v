`timescale 10ps/1ps
module uart_test_tb (    
);
    parameter PERIOD = 10;
    reg [7:0] tx_data ;
    wire [7:0] rx_data ;
    reg inclk,tx_req,rst ;
    reg rx_ack;
    wire rx_rdy,tx_ack;
    uart #(
        .PARITY("ODD")
    )   uart_inst(
        .tx_data(tx_data),
        .rx_data(rx_data),
        .inclk(inclk),
        .tx_req(tx_req),  //输入
        .tx_ack(tx_ack),  //输出
        .rst(rst),
        .rx_ack(rx_ack),  //输入
        .rx_rdy(rx_rdy)   //输出
    );
    initial begin
        inclk=0;
        #(PERIOD/2);
        forever 
        #(PERIOD/2) inclk=~inclk;
    end
    initial begin
        rst=1;
        #(PERIOD*8)
        rst=0;
    end
always @(posedge inclk or posedge rst)begin
    if(rst)begin
        tx_data <= 0;
        rx_ack <= 0;
        tx_req <= 0;
    end else begin
        if (tx_ack) begin
            tx_req <=0;
            rx_ack <=1;
        end else  begin
            tx_req <= 1;
            if(rx_rdy)tx_data <= tx_data + 3;
        end
    end
end
/*always @(posedge inclk or posedge rst) begin
    if(rst)begin
        tx_req <=0;
        rx_ack <= 0;
    end else begin
        if (!rx_ack) begin     //复位后执行一次，之后就不执行了
            tx_data <= 8'hff;
            rx_ack <= 1;
            tx_req <= 1;
        end else begin
            if (tx_ack) begin  //tx模块收到tx_data
                tx_req <= 0;
            end else if (rx_rdy) begin
                tx_req <= 1;
                tx_data <= tx_data + 2;
            end
    end
    end
end
initial begin
    tx_data =8'hff;
    #(PERIOD*4000)
    tx_req =1;
    tx_data =8'h12;
end*/
endmodule