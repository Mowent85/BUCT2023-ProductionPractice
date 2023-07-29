module top (
    input clk,                  //12MHz
    input mode,                 //待机呼吸灯模式按钮
    input song,                 //切换歌曲按钮
    input plus,                 //加秒按钮
    input minus,                //减秒按钮
    input rst,                  //重置
    input set,                  //设置确认
    input refer,                //裁判
    input player1,              //甲玩家按钮
    input player2,              //乙玩家按钮
    output reg [8:0] rope,      //拔河绳
    output reg [1:0] sel,       //位选
    output reg [1:0] ledr,      //红色LED表示设置未完成，高位为时间设置，低位为局数设置
    output reg [1:0] ledg,      //绿色LED表示设置完成，高位为时间设置，低位为局数设置
    output reg [1:0] ledb,      //蓝色LED
    output reg [3:0] ledop,     //操作指示灯
    output reg [7:0] segdata1,  //数码管1段选
    output reg [7:0] segdata0,  //数码管0段选
    output reg [7:0] seg,       //数码管显示信息
    output reg [7:0] sel8,      //8个数码管位选
    output reg ledplayer1,      //甲玩家完全胜利指示灯
    output reg ledplayer2,      //乙玩家完全胜利指示灯
    output reg buzzer,          //蜂鸣器
    output reg round_indicator_1,//甲方单局胜利指示灯
    output reg round_indicator_2//乙方单局胜利指示灯
);

wire playsong;                  //歌曲蜂鸣器
wire song_pulse;                //切换歌曲
wire mode_pulse;                //待机呼吸灯模式按钮脉冲
wire plus_pulse;                //加秒按钮脉冲
wire minus_pulse;               //减秒按钮脉冲
wire set_pulse;                 //设置按钮脉冲
wire refer_pulse;               //裁判按钮脉冲
wire player1_pulse;             //甲玩家按钮脉冲
wire player2_pulse;             //乙玩家按钮脉冲
wire [1:0] led_slowgreen;       //板载LED慢速绿色呼吸灯
wire [3:0] led_midyellow;       //板载LED中速黄色呼吸灯
wire [1:0] led_fastred;         //板载LED快速红色呼吸灯
wire [8:0] led_rope_afk1;       //扩展板设置状态拔河绳呼吸灯
wire [1:0] led_win_afk1;        //扩展板设置状态胜利指示呼吸灯
wire [1:0] led_test_afk1;       //扩展板设置状态不知道什么呼吸灯
wire [8:0] led_rope_afk2;       //扩展板设置状态拔河绳呼吸灯
wire [1:0] led_win_afk2;        //扩展板设置状态胜利指示呼吸灯
wire [1:0] led_test_afk2;       //扩展板设置状态不知道什么呼吸灯

reg gameoverflag;                   //游戏结束标志
reg win1;                       //甲玩家单局胜利信号
reg win2;                       //乙玩家单局胜利信号
reg draw;                       //平局信号
reg winflag_1;                  //蜂鸣器游戏结束反转标志
reg winflag_2;                  //拔河绳游戏结束反转闪烁标志
reg buzzerflag;                 //按键音标志
reg [1:0] modereg;              //待机呼吸灯模式
reg [3:0] cycle;                //拔河绳闪烁计数器
reg [2:0] scan;                 //数码管扫描计数器
reg [3:0] score1;               //甲玩家得分
reg [3:0] score2;               //乙玩家得分
reg [3:0] win;                  //胜利所需回合数
reg [3:0] now_round_reg1;       //当前回合十位寄存器
reg [3:0] now_round_reg0;       //当前回合个位寄存器
reg [7:0] secreg;               //秒数寄存器
reg [3:0] secreg1;              //倒计时十位寄存器
reg [3:0] secreg0;              //倒计时个位寄存器
reg [7:0] sec;                  //设定秒数
reg [3:0] sec1;                 //秒数十位
reg [3:0] sec0;                 //秒数个位
reg [4:0] now_round;            //当前局数
reg [1:0] cntdownsec;           //倒计时秒
reg [1:0] buzzer_gameover_1;    //游戏结束蜂鸣器响1次
reg [3:0] buzzer_gameover_8;    //游戏结束蜂鸣器响8次
reg [3:0] next_state;           //次态
reg [3:0] current_state;        //现态
reg [63:0] dispseg;             //显示信息寄存器
reg [23:0] flick_cnt_1Hz;       //核心板LED闪烁计数器       1s一闪
reg [23:0] flick_cnt_2Hz;       //核心板数码管闪烁计数器    0.5s一闪
reg [22:0] flick_cnt_4Hz_1;     //核心板LED闪烁计数器       0.25s一闪
reg [22:0] flick_cnt_4Hz_2;     //核心板LED闪烁计数器       0.25s一闪
reg [22:0] flick_cnt_4_33Hz;    //拔河绳LED时间计数器       3s闪13下
reg [23:0] buzzer_cnt_1Hz;      //扩展板蜂鸣器计数器        0.5s一响
reg [22:0] buzzer_cnt_4Hz;      //扩展板蜂鸣器计数器        0.25s一响
reg [25:0] buzzer_cnt_0_5Hz;    //扩展板蜂鸣器计数器        2s一响
reg [23:0] countdown_1Hz;       //核心板数码管比赛中倒计时计数器
reg [23:0] win_cnt_2Hz;         //胜利指示灯闪烁计数器      0.5s一闪

parameter init              = 4'd0;
parameter time_set          = 4'd1;
parameter round_set         = 4'd2;
parameter finish_setting    = 4'd3;
parameter counting_down     = 4'd4;
parameter gaming            = 4'd5;
parameter check             = 4'd6;
parameter gameover          = 4'd7;

//按键消抖   
debounce mode_debounce (                               
    .clk (clk),
    .rst (rst),
    .key (mode),
    .key_pulse (mode_pulse)
);
debounce song_debounce (                               
    .clk (clk),
    .rst (rst),
    .key (song),
    .key_pulse (song_pulse)
);
debounce sec_plus_debounce (                               
    .clk (clk),
    .rst (rst),
    .key (plus),
    .key_pulse (plus_pulse)
);
debounce sec_minus_debounce (                               
    .clk (clk),
    .rst (rst),
    .key (minus),
    .key_pulse (minus_pulse)
);
debounce set_debounce (                               
    .clk (clk),
    .rst (rst),
    .key (set),
    .key_pulse (set_pulse)
);
debounce refer_debounce (                               
    .clk (clk),
    .rst (rst),
    .key (refer),
    .key_pulse (refer_pulse)
);
debounce player1_debounce (                               
    .clk (clk),
    .rst (rst),
    .key (player1),
    .key_pulse (player1_pulse)
);
debounce player2_debounce (                               
    .clk (clk),
    .rst (rst),
    .key (player2),
    .key_pulse (player2_pulse)
);

//呼吸灯
breath_led_slow greenslow (
    .clk(clk),
    .rst(rst),
    .ledslow1(led_slowgreen[0]),
    .ledslow2(led_slowgreen[1])
);
breath_led_mid yellowmid (
    .clk(clk),
    .rst(rst),
    .ledmid11(led_midyellow[0]),
    .ledmid12(led_midyellow[1]),
    .ledmid21(led_midyellow[2]),
    .ledmid22(led_midyellow[3])
);
breath_led_fast redfast (
    .clk(clk),
    .rst(rst),
    .ledfast1(led_fastred[0]),
    .ledfast2(led_fastred[1])
);
breath_led_afk1 afk1(
    .clk(clk),
    .rst(rst),
    .ledafkrope(led_rope_afk1),
    .ledafk1(led_win_afk1[0]),
    .ledafk2(led_win_afk1[1]),
    .ledafk3(led_test_afk1[0]),
    .ledafk4(led_test_afk1[1]),
);
breath_led_afk2 afk2(
    .clk(clk),
    .rst(rst),
    .ledafkrope(led_rope_afk2),
    .ledafk1(led_win_afk2[0]),
    .ledafk2(led_win_afk2[1]),
    .ledafk3(led_test_afk2[0]),
    .ledafk4(led_test_afk2[1]),
);

//播放歌曲
playsongs bgm(
    .clk(clk),
    .rst(gameoverflag),
    .song(song_pulse),
    .buzzer(playsong)
);

//重置
always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        ledop[1] <= 0;
        current_state <= init;
    end
    else
    begin
        current_state <= next_state;
        ledop[1] <= 1;
    end
end

//状态转移
always @(posedge clk)
begin
    case(current_state)
    init:   next_state <= time_set;

    time_set:
    begin
        //时间设置完成
        if(set_pulse)
        next_state <= round_set;
    end

    round_set:
    begin
        //回合设置完成
        if(set_pulse)
        next_state <= finish_setting;
    end

    finish_setting:
    begin
        //裁判信号发出
        if(refer_pulse)
        next_state <= counting_down;
    end

    counting_down:
    begin
        //3秒倒计时结束进入比赛状态
        if(cntdownsec == 0)
        next_state <= gaming;
    end

    gaming:
    begin
        //倒计时未结束
        if(secreg > 0)
        begin
            //拉到两端
            if(rope[0] || rope[8])
            next_state <= check;
        end
        //倒计时结束
        else
        next_state<= check;
    end

    check:
    begin
        //若有一方达到胜利回合数，游戏结束
        if((score1 == win)|| (score2 == win))
        next_state <= gameover;
        else
        begin
            //裁判信号发出，进行新一轮
            if(refer_pulse)
            next_state <= counting_down;
        end
    end

    gameover:
    begin
        next_state <= gameover;
    end

    endcase
end

//比分更新
always @(posedge clk)
begin
    case(current_state)
    init:
    begin
        score1  <= 0;
        score2  <= 0;
        win1    <= 0;
        win2    <= 0;
        now_round<=1;
        draw    <= 0;
    end

    gaming:
    begin
        //倒计时未结束
        //拉到最左边
        if      (rope[0])   begin win1 <= 1; win2 <= 0; end
        //拉到最右边
        else if (rope[8])   begin win1 <= 0; win2 <= 1; end
        //倒计时结束      
        //绳子靠左
        else if ((rope[0]||rope[1]||rope[2]||rope[3])&&(secreg == 0)) begin win1 <= 1; win2 <= 0; end
        //绳子靠右
        else if ((rope[5]||rope[6]||rope[7]||rope[8])&&(secreg == 0)) begin win1 <= 0; win2 <= 1; end
        else if (rope[4]&&(secreg == 0)) begin draw <= 1; end
    end

    check:
    begin
        if      (win1)  begin score1 <= score1 + 1; now_round <= now_round + 1; win1 <= 0; end
        else if (win2)  begin score2 <= score2 + 1; now_round <= now_round + 1; win2 <= 0; end
        else if (draw)  begin now_round <= now_round + 1; draw <= 0; end
    end

    default:
    begin
        win1 <= 0;
        win2 <= 0;
    end
    endcase
end

//核心板LED
always @(posedge clk)
begin
    case(current_state)
    init:
    begin
        ledr    <= 2'b00;
        ledg    <= 2'b11;
        ledb    <= 2'b11;
    end

    time_set:
    begin
    if(set_pulse) //时间设置完成
    begin
        ledr[1] <= 1;
        ledg[1] <= 0;
    end
    end

    round_set:
    begin
    if(set_pulse) //回合设置完成
    begin
        ledr[0] <= 1;
        ledg[0] <= 0;
    end  
    end

    finish_setting:
    begin
        if(refer_pulse)
        begin
            ledr <= 2'b11;
            ledg <= 2'b11;
            ledb <= 2'b11;
            flick_cnt_4Hz_1 <= 0;
        end
    end

    counting_down:
    begin
        if(flick_cnt_4Hz_1 >= 3_000_000)
        begin
            ledr <= ~ledr;
            ledg <= ~ledg;
            ledb <= ~ledb;
            flick_cnt_4Hz_1 <= 0;
        end
        else flick_cnt_4Hz_1 <= flick_cnt_4Hz_1 + 1;
        if(cntdownsec == 0)
        begin
            ledr <= 2'b11;
            ledg <= 2'b11;
            ledb <= 2'b11;
        end
    end

    gaming:
    begin
        if(rope[4])
        begin
            ledg[0] <= led_slowgreen[0];
            ledg[1] <= led_slowgreen[1];
            ledr[1] <= 1;
            ledr[0] <= 1;
        end
        else if(rope[2]||rope[3]||rope[5]||rope[6])
        begin
            ledg[0] <= led_midyellow[0];
            ledr[0] <= led_midyellow[1];
            ledg[1] <= led_midyellow[2];
            ledr[1] <= led_midyellow[3];
        end
        else if(rope[0]||rope[1]||rope[7]||rope[8])
        begin
            ledg[0] <= 1;
            ledg[1] <= 1;
            ledr[0] <= led_fastred[0];
            ledr[1] <= led_fastred[1];
        end
    end

    default:
    begin
        ledr    <= 2'b11;
        ledg    <= 2'b11;
        ledb    <= 2'b11;
        flick_cnt_4Hz_1 <= 0;
    end
    endcase
end

//秒数与回合设置
always @(posedge clk)
begin
    case(current_state)
    init:
    begin
        sec     <= 5;
        win     <= 1;
    end

    time_set:
    begin
        if(plus_pulse) //增加5秒
        begin
            if (sec >= 95)
            sec <= 5;
            else
            sec <= sec + 5;
        end

        if(minus_pulse) //减少5秒
        begin
            if (sec <= 5)
            sec <= 95;
            else
            sec <= sec - 5;
        end
    end

    round_set:
    begin
        if(plus_pulse) //增加1回合
        begin
            if(win == 9) win <= 1;
            else win <= win + 1;
        end

        if(minus_pulse) //减少1回合
        begin
            if(win == 1) win <= 9;
            else win <= win - 1;
        end
    end

    default: begin win <= win; end
    endcase
end

//板载操作灯
always @(posedge clk)
begin
    case(current_state)
    init:
    begin
        ledop[3] <= 1;
        ledop[2] <= 1;
        ledop[0] <= 1;
    end

    time_set:
    begin
        if(set) ledop[0] <= 1;
        else    ledop[0] <= 0;
        if(plus)ledop[2] <= 1;
        else    ledop[2] <= 0;
        if(minus)ledop[3] <= 1;
        else    ledop[3] <= 0;
    end

    round_set:
    begin
        if(set) ledop[0] <= 1;
        else    ledop[0] <= 0;
        if(plus)ledop[2] <= 1;
        else    ledop[2] <= 0;
        if(minus)ledop[3] <= 1;
        else    ledop[3] <= 0;
    end

    default:
    begin
        ledop[3] <= 1;
        ledop[2] <= 1;
        ledop[0] <= 1;
    end
    endcase
end

//3秒倒计时
always @(posedge clk)
begin
    case(current_state)

    counting_down:
    begin
        if(flick_cnt_1Hz >= 12_000_000)
        begin
            cntdownsec <= cntdownsec - 1;
            flick_cnt_1Hz <= 0;
        end
        else flick_cnt_1Hz <= flick_cnt_1Hz + 1;
    end

    default:
    begin
        flick_cnt_1Hz <= 0;
        cntdownsec <= 3;
    end
    endcase
end

//比赛剩余时间
always @(posedge clk)
begin
    case(current_state)
    counting_down:
    begin
        secreg <= sec;
    end

    gaming:
    begin
        if(countdown_1Hz >= 12_000_000)
        begin
            countdown_1Hz <= 0;
            secreg <= secreg - 1;
        end
        else countdown_1Hz <= countdown_1Hz + 1;
    end

    check:
    begin
        //倒计时未结束
        //拉到两端
        if(rope[0]||rope[8])    secreg <= secreg;
        //倒计时结束
        if(secreg == 0)         secreg <= secreg;
    end
    endcase
end

//核心板数码管数位拆分
always @(posedge clk)
begin
    if(current_state == init)
    begin
        sec1    <= 0;
        sec0    <= 0;
        secreg1 <= 0;
        secreg0 <= 0;
        now_round_reg1 <= 0;
        now_round_reg0 <= 0;
    end
    sec0 <= sec % 10;
    sec1 <= sec / 10;
    secreg0 <= secreg % 10;
    secreg1 <= secreg / 10;
    now_round_reg0 <= now_round % 10;
    now_round_reg1 <= now_round / 10;
end

//核心板数码管位选
always @(posedge clk)
begin
    case(current_state)
    init:
    begin
        sel <= 2'b11;
        flick_cnt_2Hz <= 0;
    end
    time_set:
    begin
        if(flick_cnt_2Hz>=6_000_000)
        begin
            sel <= ~sel;
            flick_cnt_2Hz <= 0;
        end
        else flick_cnt_2Hz <= flick_cnt_2Hz + 1;
    end

    round_set:
    begin
    sel[0] <= 1;
    if(flick_cnt_2Hz>=6_000_000)
        begin
            sel[1] <= ~sel[1];
            flick_cnt_2Hz <= 0;
        end
    else flick_cnt_2Hz <= flick_cnt_2Hz + 1;
    end

    finish_setting: sel <= 2'b00;

    counting_down: sel <= 2'b10;

    gaming: sel <= 2'b00;
    

    endcase
end

//核心板与扩展板数码管段选
always @(posedge clk)
begin
    case(current_state)

    time_set:
    begin
    case(sec0)
        0: segdata0 <= 8'h3f;
        5: segdata0 <= 8'h6d;
    endcase
    case(sec1)
        0: segdata1 <= 8'h3f;
        1: segdata1 <= 8'h06;
        2: segdata1 <= 8'h5b;
        3: segdata1 <= 8'h4f;
        4: segdata1 <= 8'h66;
        5: segdata1 <= 8'h6d;
        6: segdata1 <= 8'h7d;
        7: segdata1 <= 8'h07;
        8: segdata1 <= 8'h7f;
        9: segdata1 <= 8'h6f;
    endcase
    end

    round_set:
    begin
    case(win)
        1: segdata1 <= 8'h06;
        2: segdata1 <= 8'h5b;
        3: segdata1 <= 8'h4f;
        4: segdata1 <= 8'h66;
        5: segdata1 <= 8'h6d;
        6: segdata1 <= 8'h7d;
        7: segdata1 <= 8'h07;
        8: segdata1 <= 8'h7f;
        9: segdata1 <= 8'h6f;
    endcase
    end

    finish_setting:
    begin
    case(sec0)
        0: segdata0 <= 8'h3f;
        5: segdata0 <= 8'h6d;
    endcase
    case(sec1)
        0: segdata1 <= 8'h3f;
        1: segdata1 <= 8'h06;
        2: segdata1 <= 8'h5b;
        3: segdata1 <= 8'h4f;
        4: segdata1 <= 8'h66;
        5: segdata1 <= 8'h6d;
        6: segdata1 <= 8'h7d;
        7: segdata1 <= 8'h07;
        8: segdata1 <= 8'h7f;
        9: segdata1 <= 8'h6f;
    endcase
    case(win)
    1:
    begin
        dispseg[63:56] <= 8'h06;    //1
        dispseg[55:48] <= 8'h40;    //-
        dispseg[47:40] <= 8'h3f;    //0
        dispseg[39:32] <= 8'h3f;    //0
        dispseg[31:24] <= 8'h3f;    //0
        dispseg[23:16] <= 8'h40;    //-
        dispseg[15:8]  <= 8'h40;    //-
        dispseg[7:0]   <= 8'h3f;    //0
    end
    2:
    begin
        dispseg[63:56] <= 8'h5b;    //2
        dispseg[55:48] <= 8'h40;    //-
        dispseg[47:40] <= 8'h3f;    //0
        dispseg[39:32] <= 8'h3f;    //0
        dispseg[31:24] <= 8'h3f;    //0
        dispseg[23:16] <= 8'h40;    //-
        dispseg[15:8]  <= 8'h40;    //-
        dispseg[7:0]   <= 8'h3f;    //0
    end
    3:
    begin
        dispseg[63:56] <= 8'h4f;    //3
        dispseg[55:48] <= 8'h40;    //-
        dispseg[47:40] <= 8'h3f;    //0
        dispseg[39:32] <= 8'h3f;    //0
        dispseg[31:24] <= 8'h3f;    //0
        dispseg[23:16] <= 8'h40;    //-
        dispseg[15:8]  <= 8'h40;    //-
        dispseg[7:0]   <= 8'h3f;    //0
    end
    4:
    begin
        dispseg[63:56] <= 8'h66;    //4
        dispseg[55:48] <= 8'h40;    //-
        dispseg[47:40] <= 8'h3f;    //0
        dispseg[39:32] <= 8'h3f;    //0
        dispseg[31:24] <= 8'h3f;    //0
        dispseg[23:16] <= 8'h40;    //-
        dispseg[15:8]  <= 8'h40;    //-
        dispseg[7:0]   <= 8'h3f;    //0
    end
    5:
    begin
        dispseg[63:56] <= 8'h6d;    //5
        dispseg[55:48] <= 8'h40;    //-
        dispseg[47:40] <= 8'h3f;    //0
        dispseg[39:32] <= 8'h3f;    //0
        dispseg[31:24] <= 8'h3f;    //0
        dispseg[23:16] <= 8'h40;    //-
        dispseg[15:8]  <= 8'h40;    //-
        dispseg[7:0]   <= 8'h3f;    //0
    end
    6:
    begin
        dispseg[63:56] <= 8'h7d;    //6
        dispseg[55:48] <= 8'h40;    //-
        dispseg[47:40] <= 8'h3f;    //0
        dispseg[39:32] <= 8'h3f;    //0
        dispseg[31:24] <= 8'h3f;    //0
        dispseg[23:16] <= 8'h40;    //-
        dispseg[15:8]  <= 8'h40;    //-
        dispseg[7:0]   <= 8'h3f;    //0
    end
    7:
    begin
        dispseg[63:56] <= 8'h07;    //7
        dispseg[55:48] <= 8'h40;    //-
        dispseg[47:40] <= 8'h3f;    //0
        dispseg[39:32] <= 8'h3f;    //0
        dispseg[31:24] <= 8'h3f;    //0
        dispseg[23:16] <= 8'h40;    //-
        dispseg[15:8]  <= 8'h40;    //-
        dispseg[7:0]   <= 8'h3f;    //0
    end
    8:
    begin
        dispseg[63:56] <= 8'h7f;    //8
        dispseg[55:48] <= 8'h40;    //-
        dispseg[47:40] <= 8'h3f;    //0
        dispseg[39:32] <= 8'h3f;    //0
        dispseg[31:24] <= 8'h3f;    //0
        dispseg[23:16] <= 8'h40;    //-
        dispseg[15:8]  <= 8'h40;    //-
        dispseg[7:0]   <= 8'h3f;    //0
    end
    9:
    begin
        dispseg[63:56] <= 8'h6f;    //9
        dispseg[55:48] <= 8'h40;    //-
        dispseg[47:40] <= 8'h3f;    //0
        dispseg[39:32] <= 8'h3f;    //0
        dispseg[31:24] <= 8'h3f;    //0
        dispseg[23:16] <= 8'h40;    //-
        dispseg[15:8]  <= 8'h40;    //-
        dispseg[7:0]   <= 8'h3f;    //0
    end
    endcase
    end

    counting_down:
    begin
    case(now_round_reg1)
        0: dispseg[47:40] <=8'h3f;
        1: dispseg[47:40] <=8'h06;
        2: dispseg[47:40] <=8'h5b;
        3: dispseg[47:40] <=8'h4f;
        4: dispseg[47:40] <=8'h66;
        5: dispseg[47:40] <=8'h6d;
        6: dispseg[47:40] <=8'h7d;
        7: dispseg[47:40] <=8'h07;
        8: dispseg[47:40] <=8'h7f;
        9: dispseg[47:40] <=8'h6f;
    endcase
    case(now_round_reg0)
        0: dispseg[39:32] <=8'h3f;
        1: dispseg[39:32] <=8'h06;
        2: dispseg[39:32] <=8'h5b;
        3: dispseg[39:32] <=8'h4f;
        4: dispseg[39:32] <=8'h66;
        5: dispseg[39:32] <=8'h6d;
        6: dispseg[39:32] <=8'h7d;
        7: dispseg[39:32] <=8'h07;
        8: dispseg[39:32] <=8'h7f;
        9: dispseg[39:32] <=8'h6f;
    endcase
    case(cntdownsec)   
        3: segdata0 <= 8'h4f;
        2: segdata0 <= 8'h5b;
        1: segdata0 <= 8'h06;
        0: segdata0 <= 8'h3f;
    endcase
    end

    gaming:
    begin
    case(secreg0)
        0: segdata0 <= 8'h3f;
        1: segdata0 <= 8'h06;
        2: segdata0 <= 8'h5b;
        3: segdata0 <= 8'h4f;
        4: segdata0 <= 8'h66;
        5: segdata0 <= 8'h6d;
        6: segdata0 <= 8'h7d;
        7: segdata0 <= 8'h07;
        8: segdata0 <= 8'h7f;
        9: segdata0 <= 8'h6f;
    endcase
    case(secreg1)
        0: segdata1 <= 8'h3f;
        1: segdata1 <= 8'h06;
        2: segdata1 <= 8'h5b;
        3: segdata1 <= 8'h4f;
        4: segdata1 <= 8'h66;
        5: segdata1 <= 8'h6d;
        6: segdata1 <= 8'h7d;
        7: segdata1 <= 8'h07;
        8: segdata1 <= 8'h7f;
        9: segdata1 <= 8'h6f;
    endcase
    end

    check:
    begin
    case(score1)
        0: dispseg[31:24] <= 8'h3f;
        1: dispseg[31:24] <= 8'h06;
        2: dispseg[31:24] <= 8'h5b;
        3: dispseg[31:24] <= 8'h4f;
        4: dispseg[31:24] <= 8'h66;
        5: dispseg[31:24] <= 8'h6d;
        6: dispseg[31:24] <= 8'h7d;
        7: dispseg[31:24] <= 8'h07;
        8: dispseg[31:24] <= 8'h7f;
        9: dispseg[31:24] <= 8'h6f;
    endcase
    case(score2)
        0: dispseg[7 : 0] <= 8'h3f;
        1: dispseg[7 : 0] <= 8'h06;
        2: dispseg[7 : 0] <= 8'h5b;
        3: dispseg[7 : 0] <= 8'h4f;
        4: dispseg[7 : 0] <= 8'h66;
        5: dispseg[7 : 0] <= 8'h6d;
        6: dispseg[7 : 0] <= 8'h7d;
        7: dispseg[7 : 0] <= 8'h07;
        8: dispseg[7 : 0] <= 8'h7f;
        9: dispseg[7 : 0] <= 8'h6f;
    endcase
    end

    gameover:
    begin
    if(score1 == win)
    begin
        dispseg[63:56] <= 8'h7d;
        dispseg[55:48] <= 8'h7d;
        dispseg[47:40] <= 8'h7d;
        dispseg[39:32] <= 8'h7d;
        dispseg[31:24] <= 8'h38;
        dispseg[23:16] <= 8'h3f;
        dispseg[15:8]  <= 8'h6d;
        dispseg[7:0]   <= 8'h79;
    end
    if(score2 == win)
    begin
        dispseg[63:56] <= 8'h38;
        dispseg[55:48] <= 8'h3f;
        dispseg[47:40] <= 8'h6d;
        dispseg[39:32] <= 8'h79;
        dispseg[31:24] <= 8'h7d;
        dispseg[23:16] <= 8'h7d;
        dispseg[15:8]  <= 8'h7d;
        dispseg[7:0]   <= 8'h7d;
    end
    end

    endcase
end

//扩展板数码管扫描
always @(posedge clk)
begin
    if(current_state >= finish_setting)
    begin
        scan <= scan + 1;
        case(scan)
        3'd0: begin sel8 <= 8'b1111_1110; seg <= dispseg[7:0]; end
        3'd1: begin sel8 <= 8'b1111_1101; seg <= dispseg[15:8]; end
        3'd2: begin sel8 <= 8'b1111_1011; seg <= dispseg[23:16]; end
        3'd3: begin sel8 <= 8'b1111_0111; seg <= dispseg[31:24]; end
        3'd4: begin sel8 <= 8'b1110_1111; seg <= dispseg[39:32]; end
        3'd5: begin sel8 <= 8'b1101_1111; seg <= dispseg[47:40]; end
        3'd6: begin sel8 <= 8'b1011_1111; seg <= dispseg[55:48]; end
        3'd7: begin sel8 <= 8'b0111_1111; seg <= dispseg[63:56]; end
        endcase
    end
    else sel8 <= 8'b1111_1111;
end

//拔河绳灯光控制
always @(posedge clk)
begin
    case(current_state)
    init:
    begin
        flick_cnt_4_33Hz <= 0;
        cycle <= 1;
        winflag_2 <= 0;
        rope <= 9'b0000_0_0000;
    end

    time_set:
    begin
        if      (modereg == 2'b00) rope <= led_rope_afk1;
        else if (modereg == 2'b01)
        begin
            rope[8:5] <= led_rope_afk2[8:5];
            rope[3:0] <= led_rope_afk2[3:0];
            rope[4] <= led_rope_afk2[4];
        end
        else if (modereg == 2'b10) rope <= 9'b1111_1_1111;
        else if (modereg == 2'b11) rope <= 9'b0000_0_0000;
    end

    round_set:
    begin
        if      (modereg == 2'b00) rope <= led_rope_afk1;
        else if (modereg == 2'b01)
        begin
            rope[8:5] <= led_rope_afk2[8:5];
            rope[3:0] <= led_rope_afk2[3:0];
            rope[4] <= led_rope_afk2[4];
        end
        else if (modereg == 2'b10) rope <= 9'b1111_1_1111;
        else if (modereg == 2'b11) rope <= 9'b0000_0_0000;
    end

    finish_setting: rope <= 9'b0000_0_0000;

    counting_down:
    begin
        if (flick_cnt_4_33Hz >= 2_769_230)
        begin
            cycle <= cycle + 1;
            flick_cnt_4_33Hz <= 0;
        end
        else flick_cnt_4_33Hz <= flick_cnt_4_33Hz + 1;
        case(cycle)
            1: rope <= 9'b1000_0_0001;
            2: rope <= 9'b0100_0_0010;
            3: rope <= 9'b0010_0_0100;
            4: rope <= 9'b0001_0_1000;
            5: rope <= 9'b0000_1_0000;
            6: rope <= 9'b0001_0_1000;
            7: rope <= 9'b0010_0_0100;
            8: rope <= 9'b0100_0_0010;
            9: rope <= 9'b1000_0_0001;
            10:rope <= 9'b0100_0_0010;
            11:rope <= 9'b0010_0_0100;
            12:rope <= 9'b0001_0_1000;
            13:rope <= 9'b0000_1_0000;
        endcase
    end

    gaming:
    begin
        //按钮控制拔河绳
        if(player1_pulse) rope <= {rope[7:0],rope[8]};
        if(player2_pulse) rope <= {rope[0],rope[8:1]};
    end

    check:
    begin
        if((score1==win || score2==win )) winflag_2 <= 1;
        rope <= rope;
        flick_cnt_4_33Hz <= 0;
        cycle <= 1;
    end
    
    gameover:
    begin
        if((score1==win || score2==win ) && (winflag_2 == 1))
        begin
            rope <= 9'b0101_0_1010;
            winflag_2 <= 0;
        end
        if(flick_cnt_4Hz_2 >= 3_000_000)
        begin
            rope <= ~rope;
            flick_cnt_4Hz_2 <= 0;
        end
        else flick_cnt_4Hz_2 <= flick_cnt_4Hz_2 + 1;
    end

    default:
    begin
        flick_cnt_4_33Hz <= 0;
        cycle <= 1;
    end
    endcase
end

//蜂鸣器控制
always @(posedge clk)
begin
    case(current_state)
    
    time_set:
    begin
        if(set_pulse||plus_pulse||minus_pulse||buzzerflag)
        begin
            if(buzzer_cnt_4Hz <= 1_500_000)
            begin
                buzzerflag <= 1;
                buzzer <= 1;
                buzzer_cnt_4Hz <= buzzer_cnt_4Hz + 1;
            end
            else
            begin
                buzzerflag <= 0;
                buzzer <= 0;
                buzzer_cnt_4Hz <= 0;
            end
        end
    end

    round_set:
    begin
        if(plus_pulse||minus_pulse||buzzerflag)
        begin
            if(buzzer_cnt_4Hz <= 1_500_000)
            begin
                buzzerflag <= 1;
                buzzer <= 1;
                buzzer_cnt_4Hz <= buzzer_cnt_4Hz + 1;
            end
            else
            begin
                buzzerflag <= 0;
                buzzer <= 0;
                buzzer_cnt_4Hz <= 0;
            end
        end
        if(set_pulse) buzzerflag <= 1;
    end

    finish_setting:
    begin
        if(buzzer_cnt_4Hz <= 1_500_000 && buzzerflag == 1)
        begin
            buzzerflag <= 1;
            buzzer <= 1;
            buzzer_cnt_4Hz <= buzzer_cnt_4Hz + 1;
        end
        else
        begin
            buzzerflag <= 0;
            buzzer <= 0;
            buzzer_cnt_4Hz <= 0;
        end
    end

    counting_down:
    begin
        if(buzzer_cnt_1Hz >= 6_000_000)
        begin
            buzzer <= ~buzzer;
            buzzer_cnt_1Hz <= 0;
        end
        else buzzer_cnt_1Hz <= buzzer_cnt_1Hz + 1;
    end

    check:
    begin
        if((score1==win || score2==win )) winflag_1 <= 1;
        if(buzzer_cnt_4Hz >= 1_500_000 && buzzer_gameover_8 < 8)
        begin
            buzzer <= ~buzzer;
            buzzer_cnt_4Hz <= 0;
            buzzer_gameover_8 <= buzzer_gameover_8 + 1;
        end
        else buzzer_cnt_4Hz <= buzzer_cnt_4Hz + 1;
    end

    gameover:
    begin
        if((score1==win || score2==win ) && (winflag_1 == 1))
        begin
            buzzer <= ~buzzer;
            winflag_1 <= 0;
        end
        if(buzzer_cnt_0_5Hz >= 24_000_000 && buzzer_gameover_1 < 1)
        begin
            buzzer <= ~buzzer;
            buzzer_cnt_0_5Hz <= 0;
            gameoverflag <= 1;
            buzzer_gameover_1 <= buzzer_gameover_1 + 1;
        end
        else buzzer_cnt_0_5Hz <= buzzer_cnt_0_5Hz + 1;

        if(buzzer_gameover_1 == 1)  buzzer <= playsong;
    end

    default:
    begin
        buzzer <= 0;
        buzzer_gameover_8 <= 0;
        buzzer_gameover_1 <= 0;
        buzzer_cnt_4Hz <= 0;
        buzzer_cnt_0_5Hz <= 0;
        winflag_1 <= 0;
        buzzerflag <= 0;
        gameoverflag <= 0;
    end 

    endcase
end

//胜利指示灯控制
always @(posedge clk) 
begin
    case(current_state)
    time_set:
    begin
        if(modereg == 2'b00)
        begin
            ledplayer1 <= led_win_afk1[0];  
            ledplayer2 <= led_win_afk1[1];
        end
        else if(modereg == 2'b01)
        begin
            ledplayer1 <= led_win_afk2[0];  
            ledplayer2 <= led_win_afk2[1];
        end
        else if(modereg == 2'b10)
        begin
            ledplayer1 <= 1;  
            ledplayer2 <= 1;
        end
        else if(modereg == 2'b11)
        begin
            ledplayer1 <= 0;  
            ledplayer2 <= 0;
        end
    end

    round_set:
    begin
        if(modereg == 2'b00)
        begin
            ledplayer1 <= led_win_afk1[0];  
            ledplayer2 <= led_win_afk1[1];
        end
        else if(modereg == 2'b01)
        begin
            ledplayer1 <= led_win_afk2[0];  
            ledplayer2 <= led_win_afk2[1];
        end
        else if(modereg == 2'b10)
        begin
            ledplayer1 <= 1;  
            ledplayer2 <= 1;
        end
        else if(modereg == 2'b11)
        begin
            ledplayer1 <= 0;  
            ledplayer2 <= 0;
        end
    end

    check:
    begin
        if(win_cnt_2Hz >= 3_000_000)
        begin
            win_cnt_2Hz <= 0;
            if(rope[0]||rope[1]||rope[2]||rope[3])
            ledplayer1 <= ~ledplayer1;
            if(rope[5]||rope[6]||rope[7]||rope[8])
            ledplayer2 <= ~ledplayer2;
        end
        else win_cnt_2Hz <= win_cnt_2Hz + 1;
    end

    gameover:
    begin
        if(win_cnt_2Hz >= 3_000_000)
        begin
            win_cnt_2Hz <= 0;
            if(score1 == win)
            ledplayer1 <= ~ledplayer1;
            if(score2 == win)
            ledplayer2 <= ~ledplayer2;
        end
        else win_cnt_2Hz <= win_cnt_2Hz + 1;
    end

    default:
    begin
        ledplayer1 <= 0;
        ledplayer2 <= 0;
        win_cnt_2Hz <= 0;
    end
    endcase
end

//test灯
always @(posedge clk)
begin
    case(current_state)
    time_set:
    begin
        if(modereg == 2'b00)
        begin
            round_indicator_1 <= led_test_afk1[0];
            round_indicator_2 <= led_test_afk1[1];
        end
        else if(modereg == 2'b01)
        begin
            round_indicator_1 <= led_test_afk2[0];
            round_indicator_2 <= led_test_afk2[1];
        end
        else if(modereg == 2'b10)
        begin
            round_indicator_1 <= 1;
            round_indicator_2 <= 1;
        end
        else if(modereg == 2'b11)
        begin
            round_indicator_1 <= 0;
            round_indicator_2 <= 0;
        end
    end

    round_set:
    begin
        if(modereg == 2'b00)
        begin
            round_indicator_1 <= led_test_afk1[0];
            round_indicator_2 <= led_test_afk1[1];
        end
        else if(modereg == 2'b01)
        begin
            round_indicator_1 <= led_test_afk2[0];
            round_indicator_2 <= led_test_afk2[1];
        end
        else if(modereg == 2'b10)
        begin
            round_indicator_1 <= 1;
            round_indicator_2 <= 1;
        end
        else if(modereg == 2'b11)
        begin
            round_indicator_1 <= 0;
            round_indicator_2 <= 0;
        end
    end

    default:
    begin
        round_indicator_1 <= 0;
        round_indicator_2 <= 0;
    end
    endcase
end

//待机呼吸灯模式切换
initial begin
    modereg <= 2'b00;
end
always @(posedge clk)
begin
    if(mode_pulse) modereg <= modereg + 1;
end

endmodule