module collision (
    input [9:0] x,
    input [9:0] y,
    input [1:0] level_id,
	 
    output reg is_wall // High if ANY corner hits a wall
);

    // Player size constants (32x32 pixels)
    // We check offset 31 because pixel 0 + 31 = pixel 31 (width of 32)
    parameter P_SIZE = 10'd31; 

    // Wires to catch outputs from the 4 corner checks
    wire w_tl, w_tr, w_bl, w_br;

    // 1. Check Top-Left Corner (x, y)
    map check_tl (
        .xPixel(x),
		  .yPixel(y), 
        .level_id(level_id),
		  .is_wall(w_tl)
    );

    // 2. Check Top-Right Corner (x + 31, y)
    map check_tr (
        .xPixel(x + P_SIZE), 
		  .yPixel(y), 
        .level_id(level_id), 
		  .is_wall(w_tr)
    );

    // 3. Check Bottom-Left Corner (x, y + 31)
    map check_bl (
        .xPixel(x), 
		  .yPixel(y + P_SIZE), 
        .level_id(level_id), 
		  .is_wall(w_bl)
    );

    // 4. Check Bottom-Right Corner (x + 31, y + 31)
    map check_br (
        .xPixel(x + P_SIZE), 
		  .yPixel(y + P_SIZE), 
        .level_id(level_id), 
		  .is_wall(w_br)
    );

	 always @(*) begin
		// Collision if ANY corner hits a wall
		is_wall = w_tl | w_tr | w_bl | w_br;
	 end

endmodule