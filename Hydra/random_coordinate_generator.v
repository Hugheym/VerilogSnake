
/**
 * X 8bit pseudo-random output
 * Y 7 bit output
 * constant generation, 
 */
module random_coordinate_generator(clk, en, X, Y);
	input clk;
	input en;
	output [7:0] X;
	output [6:0] Y;
	reg [7:0] X;
	reg [6:0] Y;
	wire [7:0] ranX;
	wire [6:0] ranY;
	
	Fib_LFR  Fib_LFR_instance (
		.clk(clk),
		.X(ranX),
		.Y(ranY)
	);
	
	always@(posedge en)
		begin
			X <= en ? ranX:X;
			Y <= en ? ranY:Y;
		end
	
endmodule

/*
 * Fibbonaci Linear Feedback hift regiter with 16 bit
 * X: 8bit output
 * Y: 7bit output
 */
 
 module Fib_LFR(clk, X, Y);
 	input clk;
 	output [7:0] X;
 	output [6:0] Y;
 	reg[15:0] s;
 	
 	assign X=s[14:7];
 	assign Y=s[6:0];
 	
 	initial s = 16'b1011010110100010; //seed value
 	always@(posedge clk)
 	begin
 		s[0]<= s[1]^s[2];
 		s[1]<= s[2]^s[3];
 		s[2]<= s[3]^s[4];
 		s[3]<= s[4]^s[5];
 		s[4]<= s[5]^s[6];
 		s[5]<= s[6]^s[7];
 		s[6]<= s[7]^s[8];
 		s[7]<= s[8]^s[9];
 		s[8]<= s[9]^s[10];
 		s[9]<= s[10]^s[11];
 		s[10]<= s[11]^s[12];
 		s[11]<= s[12]^s[13];
 		s[12]<= s[13]^s[14];
 		s[13]<= s[14]^s[15];
 		s[14]<= s[15]^s[1];
 		s[15]<= s[0]^s[5];
 	end		
 endmodule