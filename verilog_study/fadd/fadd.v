module fadd 
#(parameter WIDTH = 32)
(
    input                   ci,                                                                                                          
    input   [WIDTH-1:0]     a,
    input   [WIDTH-1:0]     b,
    output  [WIDTH-1:0]     sum,
    output                  co
);
    assign {co,sum}=a+b+ci;
endmodule