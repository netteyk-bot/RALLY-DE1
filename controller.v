/*
	This controller module defines the entire behavior of the players movement.
	The movement of the player is similar to that of the original Rally-X game
	(or PAC-MAN) in that you can only travel along the grid of the map and in
	such all controller inputs are delayed until the player is aligned with the
	grid. This process will be explained by comments throughout the code.
*/

module controller (
    input clk,
    input rst, 
    input [1:0] level_id,
    input btn_u, btn_d, btn_l, btn_r,
	 
    output reg [9:0] player_x,
    output reg [9:0] player_y
);

    parameter STOP  = 3'd0;
    parameter UP    = 3'd1;
    parameter DOWN  = 3'd2;
    parameter LEFT  = 3'd3;
    parameter RIGHT = 3'd4;

    reg [2:0] cur_dir; // The direction the player is currently moving
    reg [2:0] req_dir; // The direction the player WANTS to go

    reg [20:0] move_counter; // Used for slowing down player movement

    // A position is aligned if the lower 5 bits are 0 (divisible by 32)
    wire aligned = (player_x[4:0] == 5'd0) && (player_y[4:0] == 5'd0);

    // Assign user controller inputs to req_dir
    always @(posedge clk) begin
        if (rst) 
            req_dir <= STOP;
        else begin
            if (btn_u) req_dir <= UP;
            else if (btn_d) req_dir <= DOWN;
            else if (btn_l) req_dir <= LEFT;
            else if (btn_r) req_dir <= RIGHT;
        end
    end

    // TWO potential moves must be checked:
    // A. Moving in the REQUESTED direction (to see if we can turn)
    // B. Moving in the CURRENT direction (to see if we hit a wall if we don't turn)
	 

    reg [9:0] check_x_req, check_y_req;
    reg [9:0] check_x_cur, check_y_cur;

    // Calculate Position for REQUESTED Direction
    always @(*) begin
        check_x_req = player_x;
        check_y_req = player_y;
        
        case (req_dir)
            UP:    check_y_req = player_y - 10'd1;
            DOWN:  check_y_req = player_y + 10'd1;
            LEFT:  check_x_req = player_x - 10'd1;
            RIGHT: check_x_req = player_x + 10'd1;
            default: ; // Keep original position
        endcase
    end
	 
	 // Calculate Position for CURRENT Direction
    always @(*) begin
        check_x_cur = player_x;
        check_y_cur = player_y;
        
        case (cur_dir)
            UP:    check_y_cur = player_y - 10'd1;
            DOWN:  check_y_cur = player_y + 10'd1;
            LEFT:  check_x_cur = player_x - 10'd1;
            RIGHT: check_x_cur = player_x + 10'd1;
            default: ; // Keep original position
        endcase
    end

    // Collision Checkers
    wire wall_req, wall_cur;
    
    // Check Requested Direction
    collision col_checker_req (
        .x(check_x_req),
		  .y(check_y_req), 
		  .level_id(level_id),
        .is_wall(wall_req)
    );

    // Check Current Direction
    collision col_checker_cur (
        .x(check_x_cur), 
		  .y(check_y_cur), 
		  .level_id(level_id),
        .is_wall(wall_cur)
    );

    // Main Movement Logic
    always @(posedge clk) begin
        if (rst) begin
				// Spawn Location
            player_x <= 10'd160; 
            player_y <= 10'd224;
            move_counter <= 20'd0;
            cur_dir <= STOP;
        end 
        else begin
            move_counter <= move_counter + 1;
            
            // Slow down system clock to make game playable for user
            if (move_counter >= 20'd500000) begin
                move_counter <= 0;
					 
                if (aligned) begin
							// Check if aligned with grid intersection
							// If so, Try to turn (req_dir). If blocked, try straight (cur_dir). Else Stop.
                    
                    if (!wall_req && req_dir != STOP) begin
								// 1. Turn is valid
                        cur_dir <= req_dir;
                        player_x <= check_x_req;
                        player_y <= check_y_req;
                    end
						  
                    else if (!wall_cur && cur_dir != STOP) begin
								// 2. Turn blocked, but straight is valid
								// Keep cur_dir same
                        player_x <= check_x_cur;
                        player_y <= check_y_cur;
                    end
						  
                    else begin
								// 3. Both blocked (or player was already stopped)
                        cur_dir <= STOP;
                    end
                end 
                else begin
                    // Must continue in current direction until aligned
                    player_x <= check_x_cur;
                    player_y <= check_y_cur;
                end
            end
        end
    end

endmodule

// Original Constant input movement controller
/*
module controller (
    input clk,
    input rst, 
    input [1:0] level_id,
    input btn_u, btn_d, btn_l, btn_r,
    output reg [9:0] player_x,
    output reg [9:0] player_y,
    output reg touching_flag
);

    reg [20:0] move_counter; 
    reg [9:0] next_x, next_y;
    
    wire collision_wall;
    wire collision_flag;
	 
	 collision col (
        .x(next_x),
        .y(next_y),
        .level_id(level_id),
        .is_wall(collision_wall),
        .is_flag(collision_flag)
    );

    // 1. Calculate Proposed Move
    always @(*) begin
        next_x = player_x;
        next_y = player_y;
        
        if (btn_r) next_x = player_x + 10'd1;
        if (btn_l) next_x = player_x - 10'd1;
        if (btn_d) next_y = player_y + 10'd1;
        if (btn_u) next_y = player_y - 10'd1;
    end

    // 3. Movement & Event Logic
    always @(posedge clk) begin
        if (rst) begin
				// Spawn location
            player_x <= 10'd64; 
            player_y <= 10'd64;
            touching_flag <= 1'b0;
				move_counter <= 20'd0;
        end 
        else begin
            move_counter <= move_counter + 1;
				
				// Adjust this value to change player speed
            if (move_counter >= 20'd250000)
                move_counter <= 0;
            
            if (move_counter == 0) begin
                // Move if no wall
                if (!collision_wall) begin
                    player_x <= next_x;
                    player_y <= next_y;
                end
                
                touching_flag <= collision_flag;
            end
        end
    end

endmodule
*/