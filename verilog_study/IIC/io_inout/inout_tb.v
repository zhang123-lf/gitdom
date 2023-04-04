module inout_tb (
);
    reg in,control;
    wire out;
    wire IO_data;
    test_inout inout_inst(
        .in(in),
        .out(out),
        .control(control),
        .io_data(IO_data)
    );
    reg   IO_data_ff;
    assign IO_data = (~control) ? IO_data_ff : 1'bz;
    //tb只能在能够给内部输入信号的时候才能输入，
    //在io_data作为输出时（control=1），tb不能给IO_data输入信号。所以得设置为高阻态
    //在io_data作为输入时（control=0）,tb需要给IO_data输入信号，给他IO_data_ff。
    initial begin
        control = 1'b1;
        in = 1'b0;
        #10 in = 1'b1;
        #5 in = 1'b0;
        #4 control = 1'b0;
        IO_data_ff = 1'b1;
        #5 IO_data_ff = 1'b0;
        #4 IO_data_ff = 1'b1;
        
    end
endmodule
// 在描述模块功能时，input只能为wire型，
//output可以为wire或者reg型，
//inout只能为wire型； 
//在例化模块时，被例化模块的input可以为wire或者reg型，
//output只能为wire型，
//inout只能为wire型
//wire只能在assign中赋值，reg只能在wire和initial中被赋值