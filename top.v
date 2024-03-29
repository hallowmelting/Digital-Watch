module top (
input clk,
input reset_poweron,
input [3:0] btn,
output reg [7:0] seg_data,
output reg [5:0] seg_com = 6'b100000
);

wire clk_6mhz;
wire [6:0] sec0_out, sec1_out, min0_out, min1_out, hrs0_out, hrs1_out;
wire [3:0] sec0, sec1, min0, min1, hrs0, hrs1;
wire clock_en;
reg [5:0] digit = 6'b100000;
wire left, right, up, down;
wire [3:0] btn_pulse;
wire locked, rst;

//for PLL
clk_wiz_0 clk_inst (clk_6mhz, reset_poweron, locked, clk); //for Zedboard

//for reset signal generation
assign rst = reset_poweron | (~locked);

//for speed control: SIZE=6000000(x1), SIZE=600000(x10), SIZE=6000(x1000)
gen_counter_en #(.SIZE(6000000)) gen_clock_en_inst (clk_6mhz, rst, clock_en);
clock clock_inst (clk_6mhz, rst, clock_en, digit, up, down, sec0, sec1, min0, min1,
hrs0, hrs1);

// for debouncing, use btn_pulse that is high for 1 cycle)
debounce #(.BTN_WIDTH(4)) debounce_btn0_inst (clk_6mhz, rst, btn, ,btn_pulse);
assign {down, up, right, left} = btn_pulse;

//7-seg decoder
dec7 dec_sec0_inst (sec0, sec0_out);
dec7 dec_sec1_inst (sec1, sec1_out);
dec7 dec_min0_inst (min0, min0_out);
dec7 dec_min1_inst (min1, min1_out);
dec7 dec_hrs0_inst (hrs0, hrs0_out);
dec7 dec_hrs1_inst (hrs1, hrs1_out);

//digit[5:0] generation code here with "left" or "right" button
//digit[5:0] = 100000,010000,001000,000100,000010,000001,100000,010000......
always @ (posedge clk_6mhz) begin
    if (rst) digit <= 6'b100000;
    else if (right) digit <= {digit[4:0],digit[5]};
    else if (left) digit <= {digit[0],digit[5:1]};
end

//seg_com[5:0] generation code here (shifts 600 times per second)
//seg_com[5:0] = 100000,010000,001000,000100,000010,000001,100000,010000����
reg [15:0] o = 0;

always @(posedge clk_6mhz, posedge rst)
    if (rst) o <= 0;
    else
        if (o == 9999) o <= 0;
        else o <= o + 1;

wire counter_en;        
assign counter_en = (o == 9999)? 1'b1 : 1'b0;

always @ (posedge counter_en) begin //right rotation
    if (rst) seg_com <= 0;
    else seg_com <= {seg_com[0], seg_com[5:1]};
end

always @ (seg_com) begin
case (seg_com)
    6'b100000: seg_data = {sec0_out, digit[5]};
    6'b010000: seg_data = {sec1_out, digit[4]};
    6'b001000: seg_data = {min0_out, digit[3]};
    6'b000100: seg_data = {min1_out, digit[2]};
    6'b000010: seg_data = {hrs0_out, digit[1]};
    6'b000001: seg_data = {hrs1_out, digit[0]};
    default: seg_data = 8'b0;
endcase
end

endmodule