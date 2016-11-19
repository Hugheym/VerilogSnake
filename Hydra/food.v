

/*
 * on reset, generate food at new random location
 * X: 8bit x coordinates of snake's head
 * Y: 7bit y coordinates of snake's head
 */
module food(clock, X, Y, reset, foodX, foodY, collision_sig_out, plot);
	input [7:0] X;
	input [6:0] Y;
	input clock;
	input reset;
	output collision_sig_out;
	output [7:0] foodX;
	output [6:0] foodY;
	
	output reg plot;

	reg enable_gen_random;
	
	always@(*)
	begin
		if(reset)begin enable_gen_random<=1;
			plot<=1;
		end
		else begin
			enable_gen_random<=0;
			plot<=0;
		end
	end
	
	random_coordinate_generator  random_coordinate_generator_instance (
	.clk(clk),
	.en(enable_gen_random),
	.X(foodX),
	.Y(foodY));
	
	
	assign collision_sig_out = (X==foodX)&&(Y==foodY);

	

endmodule