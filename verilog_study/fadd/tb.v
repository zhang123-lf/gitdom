`timescale 1ns/1ps
module tb ();
reg ci;
reg [31:0] a,b;
wire co;
wire [31:0] sum;
fadd my_fadd(
    .ci(ci),
    .a(a),
    .b(b),
    .sum(sum),
    .co(co)
);
integer i,j;
initial begin
    ci=0 ;
    a=0;
    b=0;
    #10 ci=1;
    #20 a='d32;
    #30 b='d34;
    #123 a='d27;
    #123 b='d65;
end
//initial begin  //这个是vcs用的代码
//    $fsdbDumpfile("tb.fsdb");
//    $fsdbDumpvars(0,tb);
//    #1000 $finish;
//end
endmodule