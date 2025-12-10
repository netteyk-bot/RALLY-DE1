module flag (
    input clk,
    input rst,
    input [1:0] level_id,
    input [9:0] player_x, 
	 input [9:0] player_y,
    input [9:0] vga_x,    
	 input [9:0] vga_y,
    
    output reg flag_pixel,
    output reg all_collected
);

	 // Divide pixel position by 32 (drop lower 5 bits) to get grid coordinates
    wire [4:0] p_gx = player_x[9:5];
    wire [4:0] p_gy = player_y[9:5];
    wire [4:0] v_gx = vga_x[9:5];
    wire [4:0] v_gy = vga_y[9:5];
	 
	 // Get the local pixel coordinates (0-31) inside the grid cell (any grid)
	 wire [4:0] local_x = vga_x[4:0];
    wire [4:0] local_y = vga_y[4:0];

    reg [3:0] collected; 
    reg [3:0] active_flag;
	 reg grid_has_flag;
	 
	 // Shape math for drawing a flag
	 // Pole: A 3-pixel wide vertical line from Y=4 to Y=28
    wire is_pole_shape = (local_x >= 5'd5 && local_x <= 5'd7) && (local_y >= 5'd4 && local_y <= 5'd28);

    // Pennant: A triangle starting from the pole.
    // It exists for X > 7 and Y between 4 and 16. 
    // The right edge moves left as Y increases, creating the triangular shape.
    wire is_cloth_shape = (local_x > 5'd7) && 
                          (local_y >= 5'd4 && local_y <= 5'd16) && 
                          (local_x <= (5'd26 - (local_y - 5'd4))); 
    
    // Combined Shape: The pixel is part of the flag if it's in the pole OR the pennant.
    wire is_flag_shape = is_pole_shape | is_cloth_shape;
	 
    // COLLECTION LOGIC
    always @(posedge clk) begin
        if (rst)
				collected <= 4'b0000;
        else begin
            case(level_id)
                2'd1: begin
                    // Level 1: Flag 0 at (18, 11), Flag 1 at (7, 2)
                    if (p_gx == 5'd18 && p_gy == 5'd11)
								collected[0] <= 1'b1;
						  if (p_gx == 5'd7 && p_gy == 5'd2)
								collected[1] <= 1'b1;
                end
                2'd2: begin
                    // Level 2: Flag 0 at (18, 1), Flag 1 at (2, 11), Flag 3 at (9, 8)
                    if (p_gx == 5'd18 && p_gy == 5'd1)
								collected[0] <= 1'b1;
                    if (p_gx == 5'd2  && p_gy == 5'd11)
								collected[1] <= 1'b1;
						  if (p_gx == 5'd9 && p_gy == 5'd8)
								collected[2] <= 1'b1;
                end
					 
					 2'd3: begin
                    // Level 3
                    if (p_gx == 5'd2 && p_gy == 5'd1)
								collected[0] <= 1'b1;
                    if (p_gx == 5'd5  && p_gy == 5'd11)
								collected[1] <= 1'b1;
						  if (p_gx == 5'd18 && p_gy == 5'd11)
								collected[2] <= 1'b1;
						  if (p_gx == 5'd13 && p_gy == 5'd6)
								collected[3] <= 1'b1;
                end
            endcase
        end
    end

    // DRAWING & WIN LOGIC
    always @(*) begin
        flag_pixel = 1'b0;
        all_collected = 1'b0;
        active_flag = 1'b0;
		  grid_has_flag = 1'b0;

        case(level_id)
            // Level 1
            2'd1: begin
                active_flag = 4'b0011;
                
                // Draw Flag 0 if the current pixel being drawn is at (18,11) AND it is NOT collected
                if (v_gx == 5'd18 && v_gy == 5'd11 && !collected[0])
							grid_has_flag = 1'b1;
					 // Draw Flag 1 if the current pixel being drawn is at (7,2) AND it is NOT collected
					 if (v_gx == 5'd7 && v_gy == 5'd2 && !collected[1])
							grid_has_flag = 1'b1;
            end

            // LEVEL 2
            2'd2: begin
                active_flag = 4'b0111;

                // Draw Flag 0
                if (v_gx == 5'd18 && v_gy == 5'd1 && !collected[0])
							grid_has_flag = 1'b1;
                // Draw Flag 1
                if (v_gx == 5'd2  && v_gy == 5'd11 && !collected[1]) 
							grid_has_flag = 1'b1;
					 // Draw Flag 2
                if (v_gx == 5'd9  && v_gy == 5'd8 && !collected[2]) 
							grid_has_flag = 1'b1;
            end
				
				// LEVEL 3
            2'd3: begin
                active_flag = 4'b1111;

                // Draw Flag 0
                if (v_gx == 5'd2 && v_gy == 5'd1 && !collected[0])
							grid_has_flag = 1'b1;
                // Draw Flag 1
                if (v_gx == 5'd5  && v_gy == 5'd11 && !collected[1]) 
							grid_has_flag = 1'b1;
					 // Draw Flag 2
                if (v_gx == 5'd18  && v_gy == 5'd11 && !collected[2]) 
							grid_has_flag = 1'b1;
					 // Draw Flag 3
                if (v_gx == 5'd13  && v_gy == 5'd6 && !collected[3]) 
							grid_has_flag = 1'b1;
            end
        endcase
		  
		  // Draw flag only if in a flag grid cell AND pixel is inside flags shape
		  if (grid_has_flag && is_flag_shape) begin
            flag_pixel = 1'b1;
        end

        // Check Win Condition (flags collected == number of active flags)
        if ((active_flag != 4'd0) && (collected & active_flag) == active_flag)
            all_collected = 1'b1;
    end

endmodule