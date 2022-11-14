module clock (
input clk_6mhz,
input rst,
input clock_en,
input [5:0] digit,
input up,
input down,
output reg [3:0] sec0,
output reg [3:0] sec1,
output reg [3:0] min0,
output reg [3:0] min1,
output reg [3:0] hrs0,
output reg [3:0] hrs1
);

// trig 신호 생성
wire [4:0] trig;
assign trig[0] = (sec0 == 10)? 1'b1 : 1'b0; // 10일때 trigger
assign trig[1] = ({sec1,sec0} == 8'b0101_1010)? 1'b1 : 1'b0; // 510일때 trigger
assign trig[2] = ({min0,sec1,sec0} == 12'b1001_0101_1010)? 1'b1 : 1'b0; // 9 510일때 trigger
assign trig[3] = ({min1,min0,sec1,sec0} == 16'b0101_1001_0101_1010)? 1'b1 : 1'b0; // 59 510일때 trigger
assign trig[4] = ({hrs0,min1,min0,sec1,sec0} == 20'b1001_0101_1001_0101_1010)? 1'b1 : 1'b0; // 9 59 510일때 trigger

// 초
always @ (posedge clk_6mhz, posedge rst)
    if (rst) sec0 <= 0;
    else if (sec0 == 10) sec0 <= 0;          
    else if (up & digit[5]) begin sec0 <= sec0 + 1; if (sec0 == 9) sec0 <= 0; end
    else if (down & digit[5]) begin sec0 <= sec0 - 1; if (sec0 == 0) sec0 <= 9; end // and 연산을 통해 둘 다 1일때만 1이도록 한다.
    else if (clock_en) sec0 <= sec0 + 1;
    
always @ (posedge clk_6mhz, posedge rst)
    if (rst) sec1 <= 0;
    else if ({sec1,sec0} == 8'b0101_1010) sec1 <= 0; // 5 10일때 초기화
    else if (up & digit[4]) begin sec1 <= sec1 + 1; if (sec1 == 5) sec1 <= 0; end
    else if (down & digit[4]) begin sec1 <= sec1 - 1; if (sec1 == 0) sec1 <= 5; end
    else if (trig[0]) sec1 <= sec1 + 1;

// 분
always @ (posedge clk_6mhz, posedge rst)
    if (rst) min0 <= 0;
    else if ({min0,sec1,sec0} == 12'b1001_0101_1010) min0 <= 0; // 9 510일때 초기화
    else if (up & digit[3]) begin min0 <= min0 + 1; if (min0 == 9) min0 <= 0; end
    else if (down & digit[3]) begin min0 <= min0 - 1; if (min0 == 0) min0 <= 9; end
    else if (trig[1]) min0 <= min0 + 1;
                
always @ (posedge clk_6mhz, posedge rst)
    if (rst) min1 <= 0;
    else if ({min1,min0,sec1,sec0} == 16'b0101_1001_0101_1010) min1 <= 0; // 59 510일때 초기화
    else if (up & digit[2]) begin min1 <= min1 + 1; if (min1 == 5) min1 <= 0; end
    else if (down & digit[2]) begin min1 <= min1 - 1; if (min1 == 0) min1 <= 5; end
    else if (trig[2]) min1 <= min1 + 1;
                
// 시
always @ (posedge clk_6mhz, posedge rst)
    if (rst) hrs0 <= 0;
    else if ({hrs0,min1,min0,sec1,sec0} == 20'b1001_0101_1001_0101_1010) hrs0 <= 0;  // 9 59 510일때 초기화
    else if ({hrs1,hrs0,min1,min0,sec1,sec0} == 24'b0010_0011_0101_1001_0101_1010) hrs0 <= 0;  // 23 59 510일때 초기화 // 04 00 00를 초기화하는 코드  
    else if (up & digit[1]) begin hrs0 <= hrs0 + 1; if (hrs0 == 9) hrs0 <= 0; else if ({hrs1,hrs0} == 8'b0010_0011) hrs0 <= 0; end // 23일때 초기화
    else if (down & digit[1]) begin hrs0 <= hrs0 - 1; if (hrs0 == 0) begin if (hrs1 == 2) hrs0 <= 3; else hrs0 <= 9; end end
    else if (trig[3]) hrs0 <= hrs0 + 1;
                
always @ (posedge clk_6mhz, posedge rst)
    if (rst) hrs1 <= 0;
    else if ({hrs1,hrs0,min1,min0,sec1,sec0} == 24'b0010_0011_0101_1001_0101_1010) hrs1 <= 0;  // 23 59 510일때 초기화
    else if (up & digit[0]) begin hrs1 <= hrs1 + 1; if (hrs1 == 2) hrs1 <= 0; else if (hrs0 > 3) begin if (hrs1 == 1) hrs1 <= 0; else if (hrs1 == 0) hrs1 <= 1; end end
    else if (down & digit[0]) begin hrs1 <= hrs1 - 1; if (hrs0 > 3) begin if (hrs1 == 1) hrs1 <= 0; else if (hrs1 == 0) hrs1 <= 1; end else if (hrs1 == 0) hrs1 <= 2; end
    else if (trig[4]) hrs1 <= hrs1 + 1;

endmodule