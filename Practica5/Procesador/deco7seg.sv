// ************************
// 7-segment Decoder Module
// ************************
module deco7seg(
	input  logic [3:0] D,
	input  logic Enable,
	output logic [6:0] SEG
);
 
	always_comb begin
		if(Enable == 1'b1) begin
			case(D)				 //gfedcba
				4'b0000: SEG = 7'b1000000; // 0x40 (0)
				4'b0001: SEG = 7'b1111001; // 0x79 (1)
				4'b0010: SEG = 7'b0100100; // 0x24 (2)
				4'b0011: SEG = 7'b0110000; // 0x30 (3)
				4'b0100: SEG = 7'b0011001; // 0x19 (4)
				4'b0101: SEG = 7'b0010010; // 0x12 (5)
				4'b0110: SEG = 7'b0000010; // 0x02 (6)
				4'b0111: SEG = 7'b1111000; // 0x78 (7)
				4'b1000: SEG = 7'b0000000; // 0x00 (8)
				4'b1001: SEG = 7'b0011000; // 0x18 (9)
				
				4'b1010: SEG = 7'b0001000; // 0x08 (A)
				4'b1011: SEG = 7'b0000011; // 0x03 (b)
				4'b1100: SEG = 7'b1001110; // 0x4E (r)
				4'b1111: SEG = 7'b0111111; // 0x3F (-)
				
				default: SEG = 7'b1111111;	// 0x7F Segment Off
			endcase
		end
		else begin
			SEG = 7'b1111111;		// 0x7F Segment Off
		end
	end
endmodule
