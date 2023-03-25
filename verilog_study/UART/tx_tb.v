`timescale 10ps/1ps
module tx_tb (
);
    parameter PERIOD = 104167;
    reg clk;
    reg rst;
    reg [7:0] tx_data;
    reg tx_rdy;
    wire tx_ack;
    initial begin
        clk = 0;
        #(PERIOD/2);
        forever begin
            #(PERIOD/2) clk = ~clk;
        end
    end
    initial begin
        rst = 1;
        #(PERIOD*2);
        rst = 0;
    end
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            tx_rdy <= 0;
            tx_data <=0;
        end else begin
            if (tx_ack) begin
                tx_rdy <= 0;
                tx_data <=tx_data +1;
            end
            else if(!tx_rdy) begin
            tx_rdy <= 1'b1;
            end
        end
    end
    tx #(
        .PARITY("ODD"),
        .STOP_BIT(1)
    )
    tx_inst(
        .rst(rst),
        .clk(clk),
        .tx_data(tx_data),
        .tx_rdy(tx_rdy),
        .tx_ack(tx_ack),
        .tx(tx)
    );
    initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tx_tb);
    #5000 $finish;
end
endmodule