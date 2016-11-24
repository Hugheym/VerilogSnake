

/*
 * on reset, generate food at new random location
 * X: 8bit x coordinates of snake's head
 * Y: 7bit y coordinates of snake's head
 */
module food(clock, check_collision,X, Y, reset, foodX, foodY, collision_sig_out, plot);
	input [7:0] X;
	input [6:0] Y;
	input clock, check_collision;
	input reset;
	output collision_sig_out;
	output [7:0] foodX;
	output [6:0] foodY;
	
	output reg plot;

	reg enable_gen_random;
	
	reg [3:0] count;
	initial count = 4'b1111;
	
	always@(clock)
	begin
		plot<=0;
		enable_gen_random<=0;
		if(reset|check_collision)begin 
			enable_gen_random<=1;
			count <= 4'b1111;
		end
		else if(count==4'b1111) begin
			enable_gen_random<=0;
			count<=count-1;
		end
		else if(count==4'b1110) begin
			plot<=1;
			count<=count-1;
		end
		
	end
	
	random_coordinate_generator  random_coordinate_generator_instance (
	.clk(clock),
	.en(enable_gen_random),
	.X(foodX),
	.Y(foodY));
	
	
	assign collision_sig_out = (X==foodX)&&(Y==foodY);

	

endmodule