

module Top	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
		output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	reg [2:0] colour;
	reg [7:0] x;
	reg [6:0] y;
	wire writeEn=1;

	
	 wire go_right = !KEY[1];
    wire go_left= !KEY[2];
    wire add_x;
    wire sub_x;
    wire add_y;
    wire sub_y;
	 wire [7:0] snakeX;
	 wire [6:0] snakeY;
	 wire [7:0] foodX;
	 wire [6:0] foodY;
	 wire collision_food;
	 wire plotFood;
	wire [2:0] snakeColour;
	 wire clkA, clkB, clkC, clkD;
	 clocks cccc(.original(CLOCK_50), .sigOne(clkA), .sigTwo(clkB), .sigThree(clkC), .sigFour(clkD));
	 
	 wire realCollision;
	 assign realCollision= ((snakeX==foodX)&&(snakeY==foodY));
	 
	 food fff(.clock(clkB),.X(snakeX), .Y(snakeY), .reset((!resetn)|realCollision), .foodX(foodX), .foodY(foodY), 
	 .collision_sig_out(collision_food), .plot(plotFood));
	 
	 
	 always@(*)begin
		if(plotFood==1'b1) begin
			x<=foodX;
			y<=foodY;
			colour<=3'b100;
		end
		else
		begin
			x<=snakeX;
			y<=snakeY;
			colour<=snakeColour;
		end
	 
	 end

	
	snake_datapath snpath(.clk(clkA), 
								.resetn(resetn), 
								.add_x(add_x), 
								.add_y(add_y), 
								.sub_x(sub_x), 
								.sub_y(sub_y), 
								.out_x(snakeX), 
								.out_y(snakeY),
								.colour(snakeColour));
		
	snake_control scon(
	.clk(clkA),
   .resetn(resetn),
   .go_right(go_right),
		.go_left(go_left),
    .add_x(add_x),
    .add_y(add_y),
    .sub_x(sub_x),
    .sub_y(sub_y));
	
	vga_adapter VGA(	.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK)
			);
			defparam VGA.RESOLUTION = "160x120";
			defparam VGA.MONOCHROME = "FALSE";
			defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
			defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
			
endmodule


module clocks(original, sigOne, sigTwo, sigThree, sigFour);
	input original;
	output sigOne, sigTwo, sigThree, sigFour;
	reg [20:0] count;
	initial count=21'b011111111111111111111;
	assign sigOne = (count==21'b000000000000000000000)? 1:0;
	assign sigTwo = (count==21'b011111111111111110000);
	always@(posedge original)
	begin
		if(sigOne) count<=21'b011111111111111111111;
		else count <= count -1;
	end
	
	

endmodule