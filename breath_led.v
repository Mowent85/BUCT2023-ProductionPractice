module breath_led_slow(clk,rst,ledslow1,ledslow2);

input clk;             	//系统时钟输入
input rst;             	//复位输出
output reg ledslow1;    //led输出
output reg ledslow2;

reg [24:0] cnt1;       	//计数器1
reg [24:0] cnt2;       	//计数器2
reg flag;              	//呼吸灯变亮和变暗的标志位

parameter   CNT_NUM = 4000;	//计数器的最大值 period = (3464^2)*2 ~= 24000000 = 2s 由亮到暗1s，由暗到亮1s

//产生计数器cnt1
always@(posedge clk or negedge rst) begin 
	if(!rst) begin
		cnt1<=13'd0;
		end 
	else begin
		if(cnt1>=CNT_NUM-1) 
			cnt1<=1'b0;
		else 
			cnt1<=cnt1+1'b1; 
		end
	end

//产生计数器cnt2
always@(posedge clk or negedge rst) begin 
	if(!rst) begin
		cnt2<=13'd0;
		flag<=1'b0;
	end 
	else begin
		if(cnt1==CNT_NUM-1) begin	//当计数器1计满时计数器2开始计数加一或减一
			if(!flag) begin       	//当标志位为0时计数器2递增计数，表示呼吸灯效果由暗变亮
				if(cnt2>=CNT_NUM-1)	//计数器2计满时，表示亮度已最大，标志位变高，之后计数器2开始递减
					flag<=1'b1;
				else
					cnt2<=cnt2+1'b1;
			end 
			else begin           	//当标志位为高时计数器2递减计数
				if(cnt2<=0)         //计数器2级到0，表示亮度已最小，标志位变低，之后计数器2开始递增
					flag<=1'b0;
				else 
					cnt2<=cnt2-1'b1;
			end
		end
	else cnt2<=cnt2;   	//计数器1在计数过程中计数器2保持不变
	ledslow1 <= (cnt1<cnt2)?1'b0:1'b1;
	ledslow2 <= (cnt2<cnt1)?1'b0:1'b1;
	end
end
//比较计数器1和计数器2的值产生自动调整占空比输出的信号，输出到led产生呼吸灯效果
endmodule

module breath_led_mid(clk,rst,ledmid11,ledmid12,ledmid21,ledmid22);

input clk;             	//系统时钟输入
input rst;             	//复位输出
output reg ledmid11;    //led输出
output reg ledmid12;
output reg ledmid21;
output reg ledmid22;

reg [24:0] cnt1;       	//计数器1
reg [24:0] cnt2;       	//计数器2
reg flag;              	//呼吸灯变亮和变暗的标志位

parameter   CNT_NUM = 2400;	//计数器的最大值 period = (2400^2)*2 ~= 12000000 = 1s 由亮到暗0.5s，由暗到亮0.5s

//产生计数器cnt1
always@(posedge clk or negedge rst) begin 
	if(!rst) begin
		cnt1<=13'd0;
		end 
	else begin
		if(cnt1>=CNT_NUM-1) 
			cnt1<=1'b0;
		else 
			cnt1<=cnt1+1'b1; 
		end
	end

//产生计数器cnt2
always@(posedge clk or negedge rst) begin 
	if(!rst) begin
		cnt2<=13'd0;
		flag<=1'b0;
	end 
	else begin
		if(cnt1==CNT_NUM-1) begin	//当计数器1计满时计数器2开始计数加一或减一
			if(!flag) begin       	//当标志位为0时计数器2递增计数，表示呼吸灯效果由暗变亮
				if(cnt2>=CNT_NUM-1)	//计数器2计满时，表示亮度已最大，标志位变高，之后计数器2开始递减
					flag<=1'b1;
				else
					cnt2<=cnt2+1'b1;
			end 
			else begin           	//当标志位为高时计数器2递减计数
				if(cnt2<=0)         //计数器2级到0，表示亮度已最小，标志位变低，之后计数器2开始递增
					flag<=1'b0;
				else 
					cnt2<=cnt2-1'b1;
			end
		end
	else cnt2<=cnt2;   	//计数器1在计数过程中计数器2保持不变
	ledmid11 <= (cnt1<cnt2)?1'b0:1'b1;
	ledmid12 <= ledmid11;
	ledmid21 <= (cnt2<cnt1)?1'b0:1'b1;
	ledmid22 <= ledmid21;
	end
end
//比较计数器1和计数器2的值产生自动调整占空比输出的信号，输出到led产生呼吸灯效果

endmodule

module breath_led_fast(clk,rst,ledfast1,ledfast2);

input clk;             	//系统时钟输入
input rst;             	//复位输出
output reg ledfast1;    //led输出
output reg ledfast2;

reg [24:0] cnt1;       	//计数器1
reg [24:0] cnt2;       	//计数器2
reg flag;              	//呼吸灯变亮和变暗的标志位

parameter   CNT_NUM = 1500;	//计数器的最大值 period = (3464^2)*2 ~= 24000000 = 2s 由亮到暗1s，由暗到亮1s

//产生计数器cnt1
always@(posedge clk or negedge rst) begin 
	if(!rst) begin
		cnt1<=13'd0;
		end 
	else begin
		if(cnt1>=CNT_NUM-1) 
			cnt1<=1'b0;
		else 
			cnt1<=cnt1+1'b1; 
		end
	end

//产生计数器cnt2
always@(posedge clk or negedge rst) begin 
	if(!rst) begin
		cnt2<=13'd0;
		flag<=1'b0;
	end 
	else begin
		if(cnt1==CNT_NUM-1) begin	//当计数器1计满时计数器2开始计数加一或减一
			if(!flag) begin       	//当标志位为0时计数器2递增计数，表示呼吸灯效果由暗变亮
				if(cnt2>=CNT_NUM-1)	//计数器2计满时，表示亮度已最大，标志位变高，之后计数器2开始递减
					flag<=1'b1;
				else
					cnt2<=cnt2+1'b1;
			end 
			else begin           	//当标志位为高时计数器2递减计数
				if(cnt2<=0)         //计数器2级到0，表示亮度已最小，标志位变低，之后计数器2开始递增
					flag<=1'b0;
				else 
					cnt2<=cnt2-1'b1;
			end
		end
	else cnt2<=cnt2;   	//计数器1在计数过程中计数器2保持不变
	ledfast1 <= (cnt1<cnt2)?1'b0:1'b1;
	ledfast2 <= (cnt2<cnt1)?1'b0:1'b1;
	end
end
//比较计数器1和计数器2的值产生自动调整占空比输出                                                                                                                      的信号，输出到led产生呼吸灯效果
endmodule

module breath_led_afk1(clk,rst,ledafkrope,ledafk1,ledafk2,ledafk3,ledafk4);

input clk;             	//系统时钟输入
input rst;             	//复位输出
output reg [8:0] ledafkrope;    //led输出
output reg ledafk1;
output reg ledafk2;
output reg ledafk3;
output reg ledafk4;

reg [24:0] cnt1;       	//计数器1
reg [24:0] cnt2;       	//计数器2
reg flag;              	//呼吸灯变亮和变暗的标志位

parameter   CNT_NUM = 4000;	//计数器的最大值 period = (3464^2)*2 ~= 24000000 = 2s 由亮到暗1s，由暗到亮1s

//产生计数器cnt1
always@(posedge clk or negedge rst) begin 
	if(!rst) begin
		cnt1<=13'd0;
		end 
	else begin
		if(cnt1>=CNT_NUM-1) 
			cnt1<=1'b0;
		else 
			cnt1<=cnt1+1'b1; 
		end
	end

//产生计数器cnt2
always@(posedge clk or negedge rst) begin 
	if(!rst) begin
		cnt2<=13'd0;
		flag<=1'b0;
	end 
	else begin
		if(cnt1==CNT_NUM-1) begin	//当计数器1计满时计数器2开始计数加一或减一
			if(!flag) begin       	//当标志位为0时计数器2递增计数，表示呼吸灯效果由暗变亮
				if(cnt2>=CNT_NUM-1)	//计数器2计满时，表示亮度已最大，标志位变高，之后计数器2开始递减
					flag<=1'b1;
				else
					cnt2<=cnt2+1'b1;
			end 
			else begin           	//当标志位为高时计数器2递减计数
				if(cnt2<=0)         //计数器2级到0，表示亮度已最小，标志位变低，之后计数器2开始递增
					flag<=1'b0;
				else 
					cnt2<=cnt2-1'b1;
			end
		end
	else cnt2<=cnt2;   	//计数器1在计数过程中计数器2保持不变
	ledafkrope[8] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[7] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[6] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[5] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[4] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[3] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[2] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[1] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[0] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafk1 <= (cnt1<cnt2)?1'b0:1'b1;
	ledafk2 <= (cnt1<cnt2)?1'b0:1'b1;
	ledafk3 <= (cnt1<cnt2)?1'b0:1'b1;
	ledafk4 <= (cnt1<cnt2)?1'b0:1'b1;
	end
end
//比较计数器1和计数器2的值产生自动调整占空比输出的信号，输出到led产生呼吸灯效果
endmodule

module breath_led_afk2(clk,rst,ledafkrope,ledafk1,ledafk2,ledafk3,ledafk4);

input clk;             	//系统时钟输入
input rst;             	//复位输出
output reg [8:0] ledafkrope;    //led输出
output reg ledafk1;
output reg ledafk2;
output reg ledafk3;
output reg ledafk4;

reg [24:0] cnt1;       	//计数器1
reg [24:0] cnt2;       	//计数器2
reg flag;              	//呼吸灯变亮和变暗的标志位

parameter   CNT_NUM = 4000;	//计数器的最大值 period = (3464^2)*2 ~= 24000000 = 2s 由亮到暗1s，由暗到亮1s

//产生计数器cnt1
always@(posedge clk or negedge rst) begin 
	if(!rst) begin
		cnt1<=13'd0;
		end 
	else begin
		if(cnt1>=CNT_NUM-1) 
			cnt1<=1'b0;
		else 
			cnt1<=cnt1+1'b1; 
		end
	end

//产生计数器cnt2
always@(posedge clk or negedge rst) begin 
	if(!rst) begin
		cnt2<=13'd0;
		flag<=1'b0;
	end 
	else begin
		if(cnt1==CNT_NUM-1) begin	//当计数器1计满时计数器2开始计数加一或减一
			if(!flag) begin       	//当标志位为0时计数器2递增计数，表示呼吸灯效果由暗变亮
				if(cnt2>=CNT_NUM-1)	//计数器2计满时，表示亮度已最大，标志位变高，之后计数器2开始递减
					flag<=1'b1;
				else
					cnt2<=cnt2+1'b1;
			end 
			else begin           	//当标志位为高时计数器2递减计数
				if(cnt2<=0)         //计数器2级到0，表示亮度已最小，标志位变低，之后计数器2开始递增
					flag<=1'b0;
				else 
					cnt2<=cnt2-1'b1;
			end
		end
	else cnt2<=cnt2;   	//计数器1在计数过程中计数器2保持不变
	ledafkrope[8] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[7] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[6] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[5] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[4] <= (cnt1>cnt2)?1'b0:1'b1;
	ledafkrope[3] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[2] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[1] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafkrope[0] <= (cnt1<cnt2)?1'b0:1'b1;
	ledafk1 <= (cnt1>cnt2)?1'b0:1'b1;
	ledafk2 <= (cnt1>cnt2)?1'b0:1'b1;
	ledafk3 <= (cnt1>cnt2)?1'b0:1'b1;
	ledafk4 <= (cnt1>cnt2)?1'b0:1'b1;
	end
end
//比较计数器1和计数器2的值产生自动调整占空比输出的信号，输出到led产生呼吸灯效果
endmodule