

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




 
input clk;
input trigger;
input resetn;
input add_x;
input add_y; 
input sub_x;
input sub_y;
output reg plot;



output reg[2:0] colour; 

output reg[7:0] out_x; 
output reg[6:0] out_y;
reg [7:0] head_x;
reg [6:0] head_y;

reg [1:0] count;
initial count = 2'b00;
reg [3:0] len;
initial len=3'b011;//starting long
 
reg shift_enable;
wire [7:0] erase_x;
wire [6:0] erase_y;
wire collision;

coordinate_shifter cssss(.clk(clk), .enable(shift_enable), .length(len) ,
 .head_x(head_x), .head_y(head_y), .tail_x(erase_x), .tail_y(erase_y), .collision(collision), .reset_n(reset));


always @ (posedge clk) begin
	shift_enable=0;
	plot<=0;
	if(trigger)count<=3'b000;
	else if(count==2'b00) //ERASE STATE
		begin colour<=3'b000; 
			out_x<=erase_x;
			out_y<=erase_y;
			count<=count+1;
			plot<=1;
		end 
	 else if(count==2'b01) //move state
		begin
        head_x <= head_x + add_x - sub_x;
        head_y <= head_y + add_y - sub_y;
		  out_x<=head_x;
		  out_y<=head_y;
		  colour<=3'b010;
		  count<=count+1;
		  plot<=1;
		end
	else if (count==2'b10)
		begin
			plot<=0;
			out_x<=erase_x;
			out_y<=erase_y; //shouldn't do anything
			shift_enable=1;
			count<=count+1;
		end
	
	 end
endmodule 


module coordinate_shifter(clk, enable, length ,head_x, head_y, tail_x, tail_y, collision, reset_n);
	input clk, enable, reset_n;
	input [3:0] length; //max length is 8+4+2+1 = 15. But tail should be erased so actually 14
	input [7:0] head_x;
	input [6:0] head_y;
	output reg [7:0] tail_x;
	output reg [6:0] tail_y;
	output collision;
	wire [7:0] x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13,x14, x15;
	wire [6:0] y1, y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13,y14,y15;
	shifter_bits s1(.clk(clk), .enable(enable), .reset(reset_n) ,.in_x(head_x), .in_y(head_y),. out_x(x1), .out_y(y1) );
	shifter_bits s2(.clk(clk), .enable(enable), .reset(reset_n) ,.in_x(x1), .in_y(y1), .out_x(x2), .out_y(y2) );
	shifter_bits s3(.clk(clk), .enable(enable), .reset(reset_n) ,.in_x(x2), .in_y(y2), .out_x(x3), .out_y(y3) );
	shifter_bits s4(.clk(clk), .enable(enable), .reset(reset_n) ,.in_x(x3), .in_y(y3), .out_x(x4), .out_y(y4) );
	shifter_bits s5(.clk(clk), .enable(enable), .reset(reset_n) ,.in_x(x4), .in_y(y4), .out_x(x5), .out_y(y5) );
	shifter_bits s6(.clk(clk), .enable(enable), .reset(reset_n) ,.in_x(x5), .in_y(y5), .out_x(x6), .out_y(y6) );
	shifter_bits s7(.clk(clk), .enable(enable), .reset(reset_n) ,.in_x(x6), .in_y(y6), .out_x(x7), .out_y(y7) );
	shifter_bits s8(.clk(clk), .enable(enable),.reset(reset_n) , .in_x(x7), .in_y(y7), .out_x(x8), .out_y(y8) );
	shifter_bits s9(.clk(clk), .enable(enable),.reset(reset_n) , .in_x(x8), .in_y(y8), .out_x(x9), .out_y(y9) );
	shifter_bits s10(.clk(clk), .enable(enable),.reset(reset_n) , .in_x(x9), .in_y(y9), .out_x(x10), .out_y(y10) );
	shifter_bits s11(.clk(clk), .enable(enable),.reset(reset_n) , .in_x(x10), .in_y(y10), .out_x(x11), .out_y(y11) );
	shifter_bits s12(.clk(clk), .enable(enable), .reset(reset_n) ,.in_x(x11), .in_y(y11), .out_x(x12), .out_y(y12) );
	shifter_bits s13(.clk(clk), .enable(enable),.reset(reset_n) , .in_x(x12), .in_y(y12), .out_x(x13), .out_y(y13) );
	shifter_bits s14(.clk(clk), .enable(enable),.reset(reset_n) , .in_x(x13), .in_y(y13), .out_x(x14), .out_y(y14) );
	shifter_bits s15(.clk(clk), .enable(enable),.reset(reset_n) , .in_x(x14), .in_y(y14), .out_x(x15), .out_y(y15) );
	
	wire [12:0] collision_wires;
	reg [12:0] collision_bitmask;
	initial collision_bitmask = 15'd0;
	bit_mask_13 bmmm(collision_wires, collision_bitmask, collision);
	collision col1(.AX(head_x), .AY(head_y), .BX(x2), .BY(y2), .outSignal(collision_wires[0]));
	collision col2(.AX(head_x), .AY(head_y), .BX(x3), .BY(y3), .outSignal(collision_wires[1]));
	collision col3(.AX(head_x), .AY(head_y), .BX(x4), .BY(y4), .outSignal(collision_wires[2]));
	collision col4(.AX(head_x), .AY(head_y), .BX(x5), .BY(y5), .outSignal(collision_wires[3]));
	collision col5(.AX(head_x), .AY(head_y), .BX(x6), .BY(y6), .outSignal(collision_wires[4]));
	collision col6(.AX(head_x), .AY(head_y), .BX(x7), .BY(y7), .outSignal(collision_wires[5]));
	collision col7(.AX(head_x), .AY(head_y), .BX(x8), .BY(y8), .outSignal(collision_wires[6]));
	collision col8(.AX(head_x), .AY(head_y), .BX(x9), .BY(y9), .outSignal(collision_wires[7]));
	collision col9(.AX(head_x), .AY(head_y), .BX(x10), .BY(y10), .outSignal(collision_wires[8]));
	collision col10(.AX(head_x), .AY(head_y), .BX(x11), .BY(y11), .outSignal(collision_wires[9]));
	collision col11(.AX(head_x), .AY(head_y), .BX(x12), .BY(y12), .outSignal(collision_wires[10]));
	collision col12(.AX(head_x), .AY(head_y), .BX(x13), .BY(y13), .outSignal(collision_wires[11]));
	collision col13(.AX(head_x), .AY(head_y), .BX(x14), .BY(y14), .outSignal(collision_wires[12]));
	
	always@(*)
		begin
			case(length)
				1: begin tail_x=x2; tail_y=y2; end
				2: begin tail_x=x3; tail_y=y3;collision_bitmask[0]=1;end
				3: begin tail_x=x4; tail_y=y4;collision_bitmask[1]=1;end
				4: begin tail_x=x5; tail_y=y5;collision_bitmask[2]=1;end
				5: begin tail_x=x6; tail_y=y6;collision_bitmask[3]=1;end
				6: begin tail_x=x7; tail_y=y7;collision_bitmask[4]=1;end
				7: begin tail_x=x8; tail_y=y8;collision_bitmask[5]=1;end
				9: begin tail_x=x9; tail_y=y9;collision_bitmask[6]=1;end
				10: begin tail_x=x10; tail_y=y10;collision_bitmask[7]=1;end
				11: begin tail_x=x11; tail_y=y11;collision_bitmask[8]=1;end
				12: begin tail_x=x12; tail_y=y12;collision_bitmask[9]=1;end
				13: begin tail_x=x13; tail_y=y13;collision_bitmask[10]=1;end
				14: begin tail_x=x14; tail_y=y14;collision_bitmask[11]=1;end
				15: begin tail_x=x15; tail_y=y15;collision_bitmask[12]=1;end
			endcase
		end
endmodule

module bit_mask_13(s, m, out);
	input [12:0] s, m;
	output out;
	assign out = ((s[0]&m[0])|(s[1]&m[1])|(s[2]&m[2])|(s[3]&m[3])|(s[4]&m[4])|(s[5]&m[5])|(s[6]&m[6])|(s[7]&m[7])|(s[8]&m[8])|(s[9]&m[9])|(s[10]&m[10])|(s[11]&m[11])|(s[12]&m[12]));
endmodule

module shifter_bits(clk, enable, reset,in_x, in_y, out_x, out_y);
	input clk, enable, reset;
	input [7:0] in_x;
	input [6:0] in_y;
	output reg [7:0] out_x;
	output reg [6:0] out_y;
	initial out_x = 8'd0;
	initial out_y = 8'd0;
	always @ (posedge clk, posedge reset) begin //async reset
		if(reset)
		begin 
			out_x<=8'd0;
			out_y<=8'd0;
		end
		else if(enable)
			begin
				out_x <= in_x;
				out_y <= in_y;
			end
	end
endmodule

// Quartus Prime Verilog Template
// One-bit wide, N-bit long shift register with asynchronous reset

module basic_shift_register_asynchronous_reset
#(parameter N=15)
(
	input clk, enable, reset,
	input sr_in,
	output sr_out
);

	// Declare the shift register
	reg [N-1:0] sr;

	// Shift everything over, load the incoming bit
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1'b1)
		begin
			// Load N zeros 
			sr <= {N{1'b0}};
		end
		else if (enable == 1'b1)
		begin
			sr[N-1:1] <= sr[N-2:0];
			sr[0] <= sr_in;
		end
	end

	// Catch the outgoing bit
	assign sr_out = sr[N-1];

endmodule


