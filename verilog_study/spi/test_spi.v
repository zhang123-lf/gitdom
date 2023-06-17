module test_spi (
    input       clk,
    input       cs,
    output      sclk,
    input       miso,
    output reg  mosi=1
);
    reg [7:0] tx_data = 8'h6a;
    always @(posedge clk ) begin
        if (~cs) begin
            tx_data <= {tx_data[6:0],1'b1};
        end
    end
    always @(posedge clk ) begin
        mosi <= tx_data[7];
    end
    assign sclk = cs?1'b0:~clk;
    reg [7:0] rx_data = 8'hff;
    always @(posedge clk ) begin
        rx_data <= {rx_data[6:0],miso};
    end
endmodule