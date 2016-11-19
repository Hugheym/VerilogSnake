

module snake_control(
	input clk,
    input resetn,
    input go_right,
    input go_left,
    output reg add_x,
    output reg add_y,
    output reg sub_x,
    output reg sub_y);


reg [2:0] current_state, next_state;
reg drawing, counter; 

localparam  	S_MOVE_RIGHT        = 3'd0,
                S_MOVE_RIGHT_WAIT   = 3'd1,
                S_MOVE_DOWN         = 3'd2,
                S_MOVE_DOWN_WAIT    = 3'd3,
                S_MOVE_LEFT         = 3'd4,
                S_MOVE_LEFT_WAIT    = 3'd5,
                S_MOVE_UP  	        = 3'd6, 
                S_MOVE_UP_WAIT      = 3'd7;
    


always@(*)
    begin: state_table 
            case (current_state)
                S_MOVE_RIGHT: begin 
                    if (go_right | go_left) 
                        next_state = S_MOVE_RIGHT;
                    else
                        next_state = S_MOVE_RIGHT_WAIT;
                    end 
                S_MOVE_RIGHT_WAIT: begin 
                    if (go_right)
                        next_state = S_MOVE_DOWN;
                    else if (go_left)
                        next_state = S_MOVE_UP;
                    else 
                        next_state = S_MOVE_RIGHT_WAIT;
                    end
                S_MOVE_DOWN: begin 
                    if (go_right | go_left)
                        next_state = S_MOVE_DOWN;
                    else 
                        next_state = S_MOVE_DOWN_WAIT;
                    end
                S_MOVE_DOWN_WAIT: begin 
                    if (go_right) 
                        next_state = S_MOVE_LEFT; 
                    else if (go_left)
                        next_state = S_MOVE_RIGHT;
                    else
                        next_state = S_MOVE_DOWN_WAIT;
						end
                S_MOVE_LEFT: begin 
                    if (go_right | go_left) 
                        next_state = S_MOVE_LEFT; 
                    else 
                        next_state = S_MOVE_LEFT_WAIT; 
                    end 
                S_MOVE_LEFT_WAIT: begin 
                    if (go_right)
                        next_state = S_MOVE_UP;
                    else if (go_left) 
                        next_state = S_MOVE_DOWN;
                    else 
                        next_state = S_MOVE_LEFT_WAIT;
                    end 
                S_MOVE_UP: begin 
                    if (go_right | go_left)
                        next_state = S_MOVE_UP;
                    else
                        next_state = S_MOVE_UP_WAIT; 
                    end
                S_MOVE_UP_WAIT: begin 
                    if (go_right) next_state = S_MOVE_RIGHT;
                    else if (go_left) next_state = S_MOVE_LEFT; 
                    else next_state = S_MOVE_UP_WAIT;
                    end 
                default: begin 
						next_state = S_MOVE_RIGHT;
						end
            endcase
        end

    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        add_x = 1'b0;
        add_y = 1'b0;
        sub_x = 1'b0;
        sub_y = 1'b0;

        case (current_state)
            S_MOVE_RIGHT: begin
                add_x = 1'b1;
            end
            S_MOVE_RIGHT_WAIT: begin
                add_x = 1'b1;
            end
            S_MOVE_DOWN: begin
            	add_y = 1'b1;
            end 
            S_MOVE_DOWN_WAIT: begin
                add_y = 1'b1;
            end 
            S_MOVE_LEFT: begin 
            	sub_x = 1'b1;
            end
            S_MOVE_LEFT_WAIT: begin 
                sub_x = 1'b1;
            end
            S_MOVE_UP: begin 
                sub_y = 1'b1;
            end
            S_MOVE_UP_WAIT: begin 
                sub_y = 1'b1;
            end
        endcase
		  end




    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_MOVE_RIGHT;
        else begin
            current_state <= next_state;
            end
    end // state_FFS

endmodule




module snake_datapath(clk, resetn, add_x, add_y, sub_x, sub_y, out_x, out_y, colour);
input clk;
input resetn;
input add_x;
input add_y; 
input sub_x;
input sub_y;



output reg[2:0] colour; 

output reg[7:0] out_x; 
output reg[6:0] out_y;
reg [1:0] count;
initial count = 2'b00;

always @ (posedge clk) begin
	count <= count+1;
	if (!resetn) begin 
        out_x <= 8'b0;
        out_y <= 7'b0;
		  count <= 2'b00;
    end 
	 else if(count==2'b00) colour<=3'b000;
	 else if(count==2'b01) 
		begin
        out_x <= out_x + add_x - sub_x;
        out_y <= out_y + add_y - sub_y;
		  colour<=3'b010;
		end
	else
		colour<=3'b010;
	 end
	

endmodule 