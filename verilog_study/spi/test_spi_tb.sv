`timescale 10ps/1ps
module test_spi_tb (
);
    wire mosi,sclk;
    reg clk,cs,miso;
    initial begin
        clk = 1'b0;
        cs = 1'b1;
        miso = 1'b0;
        miso =mosi;
    end 
    test_spi test_spi_inst(
        .clk(clk),
        .mosi(mosi),
        .sclk(sclk),
        .cs(cs),
        .miso(miso)
    );
endmodule