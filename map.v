module map (
    input [9:0] xPixel,
    input [9:0] yPixel,
    input [1:0] level_id,
	 
    output reg is_wall
);

	 // Divide pixel position by 32 (drop lower 5 bits) to get grid coordinates
    wire [4:0] gx = xPixel[9:5]; // Grid X (0-19)
    wire [4:0] gy = yPixel[9:5]; // Grid Y (0-14)

    always @(*) begin
        is_wall = 0;

        // Common Borders (Walls around the edge plus fuel gauge zone exist in all levels)
        if (gx == 5'd0 || gx == 5'd19 || gy == 5'd0 || gy == 5'd14) 
            is_wall = 1'b1;
		  if ((gy == 5'd13 || gy == 5'd12) && (gx == 5'd18 || gx == 5'd17 || gx == 5'd16 || gx == 5'd15))
				is_wall = 1'b1;
        
        else begin
            // Hardcoded specific levels
            case (level_id)
                // LEVEL 1
                2'd1: begin
							// Simple vertical wall in the middle
							if (gx == 5'd10 && gy > 5'd2 && gy < 5'd12)
								is_wall = 1'b1;
                end

                // LEVEL 2
                2'd2: begin
							if (gy == 5'd5 && gx > 5'd7 && gx < 5'd16)
								is_wall = 1'b1;
							if (gx == 5'd7 && gy > 5'd4 && gy < 5'd12)
								is_wall = 1'b1;
							if (gy == 5'd9 && gx > 5'd0 && gx < 5'd7)
								is_wall = 1'b1;
                end
					 
					 // Level 3
					 2'd3: begin
							if (gy == 5'd2 && gx >= 5'd2 && gx <= 5'd3)
								is_wall = 1'b1;
							if (gy >= 5'd1 && gy <= 5'd2 && gx >= 5'd5 && gx <= 5'd7)
								is_wall = 1'b1;
							if ((gy == 5'd4 || gy == 5'd6 || gy == 5'd8) && gx >= 5'd3 && gx <= 5'd7)
								is_wall = 1'b1;
							if (gx == 5'd3 && gy >= 5'd9 && gy <= 5'd10)
								is_wall = 1'b1;
							if (gx == 5'd1 && gy >= 5'd10 && gy <= 5'd13)
								is_wall = 1'b1;
							if (gy == 5'd12 && gx >= 5'd3 && gx <= 5'd6)
								is_wall = 1'b1;
							if (gx == 5'd6 && gy >= 5'd10 && gy <= 5'd11)
								is_wall = 1'b1;
							if (gx == 5'd7 && gy == 5'd10)
								is_wall = 1'b1;
							if (gy == 5'd12 && gx >= 5'd8 && gx <= 5'd11)
								is_wall = 1'b1;
							if (gx == 5'd10 && gy >= 5'd3 && gy <= 5'd9)
								is_wall = 1'b1;
							if (gy == 5'd9 && gx >= 5'd11 && gx <= 5'd16)
								is_wall = 1'b1;
							if (gx == 5'd13 && gy >= 5'd10 && gy <= 5'd12)
								is_wall = 1'b1;
							if (gy == 5'd1 && gx >= 5'd12 && gx <= 5'd18)
								is_wall = 1'b1;
							if (gy == 5'd3 && gx >= 5'd12 && gx <= 5'd16)
								is_wall = 1'b1;
							if (gx == 5'd12 && gy >= 5'd4 && gy <= 5'd7)
								is_wall = 1'b1;
							if (gy == 5'd7 && gx >= 5'd13 && gx <= 5'd16)
								is_wall = 1'b1;
							if (gy == 5'd5 && gx >= 5'd14 && gx <= 5'd16)
								is_wall = 1'b1;
                end
                
                default: ; // Do nothing (empty map)
            endcase
        end
    end
endmodule