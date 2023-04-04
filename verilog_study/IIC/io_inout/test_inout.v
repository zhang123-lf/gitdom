module test_inout (     //三态门
    input in,
    input control,
    output out,
    inout io_data
);
    assign io_data = control? in: 1'bz;
    assign out =io_data;
endmodule