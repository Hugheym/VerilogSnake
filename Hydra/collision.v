

/*
 * AX: 8bit X coordinates of A
 * AY: 7bit Y coordinates of A
 * 
 * outSignal = (AX==BX)&&(AY==BY);
 */
module collision(AX, AY, BX, BY, outSignal);
	input [7:0] AX, BX;
	input [6:0] AY, BY;
	output outSignal;
	assign outSignal = ((AX==BX)&&(AY==BY));
endmodule