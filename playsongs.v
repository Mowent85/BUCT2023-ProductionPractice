module playsongs(
    input clk,
    input rst,
    input song,
    output reg buzzer
);

parameter   sil= 44000, //休止符
            do = 45871, //261.6Hz
            re = 40872, //293.6Hz
            mi = 36407, //329.6Hz
            fa = 34364, //349.2Hz
            so = 30612, //392Hz
            la = 27272, //440Hz
            si = 24301, //493.8Hz
            stoptime= 110,
            dotime  = 131,
            retime  = 146,
            mitime  = 165,
            fatime  = 174,
            sotime  = 196,
            latime  = 220,
            sitime  = 247;

reg [16:0]	cnt0;	    //计数每个音符对应的时序周期
reg [10:0]	cnt1;	    //计数每个音符重复次数
reg	[6 :0]	cnt2;	    //计数曲谱中音符个数

reg	[16:0]	pre_set;	//预装载值
wire[16:0]	pre_div;	//占空比

reg	[10:0]	cishu;	    //定义不同音符重复不同次数
wire[10:0]	cishu_div;	//音符重复次数占空比

reg [1: 0]  flag;	    //歌曲种类标志：00欢乐颂，01小星星，10两只老虎，11静音
reg	[6 :0]	YINFU;	    //定义曲谱中音符个数

//歌曲种类标志位
always @(posedge clk or negedge rst)
begin
    if(!rst)        flag <= 2'b00;
    else if(song)   flag <= flag + 1;
end

//重设音符的个数
always @(posedge clk or negedge rst)
begin
    if(!rst)                YINFU <= 66;
    else if(flag == 2'b00)  YINFU <= 66;
    else if(flag == 2'b01)  YINFU <= 48;
    else if(flag == 2'b10)  YINFU <= 36;
    else                    YINFU <= 1;
end

//计数每个音符的周期，也就是表示音符的一个周期
always @(posedge clk or negedge rst)
begin
    if(!rst)                    cnt0 <= 0;
    else if(flag == 2'b11)      cnt0 <= 0;
    else if(song)               cnt0 <= 0;
    else
    begin
        if(cnt0 == pre_set - 1) cnt0 <= 0;
        else                    cnt0 <= cnt0 + 1;
    end
end

//计数每个音符重复次数，也就是表示一个音符的响鸣持续时长
always @(posedge clk or negedge rst)
begin
    if(!rst)                    cnt1 <= 0;
    else if(flag == 2'b11)      cnt1 <= 0;
    else if(song)               cnt1 <= 0;
    else
    begin
        if(cnt0 == pre_set - 1)
        begin
            if(cnt1 == cishu)   cnt1 <= 0;
            else                cnt1 <= cnt1 + 1;
        end
    end
end

//计数有多少个音符，也就是曲谱中有共多少个音符
always @(posedge clk or negedge rst)
begin
    if(!rst)                        cnt2 <= 0;
    else if(flag == 2'b11)          cnt2 <= 0;
    else if(song)                   cnt2 <= 0;
    else
    begin
        if(cnt1 == cishu && cnt0 == pre_set - 1)
        begin
            if(cnt2 == YINFU - 1)   cnt2 <= 0;
            else                    cnt2 <= cnt2 + 1;
        end
    end
end

//定义音符重复次数
always @(*)
begin
    case(pre_set)
        sil:cishu<= stoptime;
        do:cishu <= dotime;
        re:cishu <= retime;
        mi:cishu <= mitime;
        fa:cishu <= fatime;
        so:cishu <= sotime;
        la:cishu <= latime;
        si:cishu <= sitime;
    endcase
end

//曲谱定义
always @(*)
begin
    if(flag == 2'b00)
    begin
        case(cnt2)	//欢乐颂歌谱
            0 : pre_set <= mi;
            1 : pre_set <= mi;
            2 : pre_set <= fa;
            3 : pre_set <= so;
            4 : pre_set <= so;
            5 : pre_set <= fa;
            6 : pre_set <= mi;
            7 : pre_set <= re;
            8 : pre_set <= do;
            9 : pre_set <= do;
            10: pre_set <= re;
            11: pre_set <= mi;            
            12: pre_set <= mi;
            13: pre_set <= re;
            14: pre_set <= re;
            15: pre_set <= sil;
            
            16: pre_set <= mi;
            17: pre_set <= mi;
            18: pre_set <= fa;
            19: pre_set <= so;
            20: pre_set <= so;
            21: pre_set <= fa;
            22: pre_set <= mi;
            23: pre_set <= re;
            24: pre_set <= do;
            25: pre_set <= do;
            26: pre_set <= re;
            27: pre_set <= mi;
            28: pre_set <= re;
            29: pre_set <= do;
            30: pre_set <= do;
            31: pre_set <= sil;
            
            32: pre_set <= re;
            33: pre_set <= re;
            34: pre_set <= mi;
            35: pre_set <= do;
            36: pre_set <= re;
            37: pre_set <= mi;
            38: pre_set <= fa;
            39: pre_set <= mi;
            40: pre_set <= do;
            41: pre_set <= re;
            42: pre_set <= mi;
            43: pre_set <= fa;
            44: pre_set <= mi;
            45: pre_set <= re;
            46: pre_set <= do;
            47: pre_set <= re;
            48: pre_set <= so;
            49: pre_set <= sil;
            
            50: pre_set <= mi;
            51: pre_set <= mi;
            52: pre_set <= fa;
            53: pre_set <= so;
            54: pre_set <= so;
            55: pre_set <= fa;
            56: pre_set <= mi;
            57: pre_set <= re;
            58: pre_set <= do;
            59: pre_set <= do;
            60: pre_set <= re;
            61: pre_set <= mi;
            62: pre_set <= re;
            63: pre_set <= do;
            64: pre_set <= do;
            65: pre_set <= sil;
        endcase
    end
    else if (flag == 2'b01)
    begin
        case(cnt2)	//小星星歌谱
            0 : pre_set <= do;
            1 : pre_set <= do;
            2 : pre_set <= so;
            3 : pre_set <= so;
            4 : pre_set <= la;
            5 : pre_set <= la;
            6 : pre_set <= so;
            7 : pre_set <= sil;
            
            8 : pre_set <= fa;
            9 : pre_set <= fa;
            10: pre_set <= mi;
            11: pre_set <= mi;
            12: pre_set <= re;
            13: pre_set <= re;
            14: pre_set <= do;
            15: pre_set <= sil;
            
            16: pre_set <= so;
            17: pre_set <= so;
            18: pre_set <= fa;
            19: pre_set <= fa;
            20: pre_set <= mi;
            21: pre_set <= mi;
            22: pre_set <= re;
            23: pre_set <= sil;
            
            24: pre_set <= so;
            25: pre_set <= so;
            26: pre_set <= fa;
            27: pre_set <= fa;
            28: pre_set <= mi;
            29: pre_set <= mi;
            30: pre_set <= re;
            31: pre_set <= sil;
            
            32: pre_set <= do;
            33: pre_set <= do;
            34: pre_set <= so;
            35: pre_set <= so;
            36: pre_set <= la;
            37: pre_set <= la;
            38: pre_set <= so;
            39: pre_set <= sil;
            
            40: pre_set <= fa;
            41: pre_set <= fa;
            42: pre_set <= mi;
            43: pre_set <= mi;
            44: pre_set <= re;
            45: pre_set <= re;
            46: pre_set <= do;
            47: pre_set <= sil;
        endcase
    end
    else if (flag == 2'b10)
    begin
        case(cnt2)	//两只老虎歌谱
            0 : pre_set <= do;
            1 : pre_set <= re;
            2 : pre_set <= mi;
            3 : pre_set <= do;
            4 : pre_set <= do;
            5 : pre_set <= re;
            6 : pre_set <= mi;
            7 : pre_set <= do;
            8 : pre_set <= mi;
            9 : pre_set <= fa;
            10: pre_set <= so;
            11: pre_set <= sil;
            12: pre_set <= mi;
            13: pre_set <= fa;
            14: pre_set <= so;
            15: pre_set <= sil;
            
            16: pre_set <= so;
            17: pre_set <= la;
            18: pre_set <= so;
            19: pre_set <= fa;
            20: pre_set <= mi;
            21: pre_set <= do;
            22: pre_set <= so;
            23: pre_set <= la;
            24: pre_set <= so;
            25: pre_set <= fa;
            26: pre_set <= mi;
            27: pre_set <= do;
            28: pre_set <= re;
            29: pre_set <= so;
            30: pre_set <= do;
            31: pre_set <= sil;
            32: pre_set <= re;
            33: pre_set <= so;
            34: pre_set <= do;
            35: pre_set <= sil;
        endcase
    end
    else    pre_set <= sil;
end

assign pre_div = pre_set / 2;
//占空比
assign cishu_div = cishu * 4 / 5;

//向蜂鸣器输出脉冲
always @(posedge clk or negedge rst)
begin
    if(!rst)                    buzzer <= 0;
    else if(pre_set != sil)
    begin
        if(cnt1 < cishu_div)
        begin
            if(cnt0 < pre_div)  buzzer <= 0;
            else                buzzer <= 1;
        end
        else                    buzzer <= 0;
    end
    else                        buzzer <= 0;
end

endmodule
