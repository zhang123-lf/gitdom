# Verilog的Vs code环境使用（modelsim）
## 加入modelsim的逻辑库  

在控制台终端输入 `vlib work`  
**ctr** + **s** 将文件保存即可发现代码中的语法错误

## vs code直接调用modelsim仿真

1.在控制台终端输入 `vlog file_path/*.v`或者`vlog *v` 即可对该文件夹下的所.v文件进行编译  
2.进行仿真，输入 `vsim bcdtest -voptargs=+acc` 这里的`bcdtest`为测试激励的**模块名**，后面的`-voptargs=+acc`最好加上，否则新版本的modelsim很容易被object给优化掉**查看状态机**后加`-fsmdebug`
3.modelsim仿真时长可以直接在命令面板直接输入`run 10ns`**仿真时间不能超过1s**
## 删除work库输入`rm -r work`
# vcs和verdi使用
## 创建一个makefile脚本，内容为：  
<pre>vcs  :
	vcs  \
		-f filelist.f  \
		-timescale=1ns/1ps \
		-full64  -R  +vc  +v2k  -sverilog -debug_access+all\
		|  tee  vcs.log 
</pre>
<pre>verdi  :
	verdi -f filelist.f -ssf tb.fsdb &amp;
</pre>  
<pre>clean  :
	 rm  -rf  *~  core  csrc  simv*  vc_hdrs.h  ucli.key  urg* *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vpd
</pre>  
这上面只有vcs、verdi和clean的，其余的我不会 
## 还要再建个**filelist.f**
<pre>./fifo.v
./fifo_tb.sv
</pre>

## 需要再testbench中加入生成fsdb文件代码为：  
<pre>initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,fifo_tb);
    #1000 $finish;
end
</pre>
