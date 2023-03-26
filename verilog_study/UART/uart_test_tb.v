`timescale 10ps/1ps
module uart_test_tb (    
);
    parameter PERIOD = 10;
    reg [7:0] tx_data ;
    wire [7:0] rx_data ;
    reg inclk,tx_req,rst ;
    reg rx_ack;
    wire tx,rx_rdy,tx_ack;
    uart #(
        .PARITY("ODD")
    )   uart_inst(
        .tx_data(tx_data),
        .rx_data(rx_data),
        .inclk(inclk),
        .tx_req(tx_req),
        .tx_ack(tx_ack),
        .tx(tx),
        .rst(rst),
        .rx_ack(rx_ack),
        .rx_rdy(rx_rdy)
    );
    initial begin
        inclk=0;
        #(PERIOD/2);
        forever 
        #(PERIOD/2) inclk=~inclk;
    end
    initial begin
        rst=1;
        #(PERIOD*2)
        rst=0;
    end
always @(posedge inclk or posedge rst) begin
    if(rst)begin
        tx_req <=0;
        tx_data <=1;
    end else begin
        if(tx_ack) begin
            tx_req<=0;
            tx_data<=tx_data+1;
        end
        else if(!tx_req)
            tx_req<=1;
    end
end
initial begin

    rx_ack =1;

end
endmodule