module rally_de1 (
    input CLOCK_50,
    input [3:0] KEY, // KEY[3:0] = Up, Down, Left, Right
    input [9:0] SW, // SW[0]=Lvl1, SW[1]=Lvl2
	 
    // VGA Outputs
    output VGA_CLK,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output reg [7:0] VGA_R,
    output reg [7:0] VGA_G,
    output reg [7:0] VGA_B
);

    // Signals
    wire clk = CLOCK_50;
    wire [1:0] current_level;
    wire game_active;
    wire [1:0] game_state;
    wire pixel_wall;
	 wire pixel_flag;
	 wire all_collected;
	 wire time_out;
    wire [6:0] fuel_width;
    
    // VGA Position
    wire [9:0] xPixel, yPixel;
    wire active_pixels;

    // Player Position
    wire [9:0] p_x, p_y;
	 
	 // Divide pixel position by 32 (drop lower 5 bits) to get grid coordinates
    wire [4:0] gx = xPixel[9:5]; // Grid X (0-19)
    wire [4:0] gy = yPixel[9:5]; // Grid Y (0-14)

    // 2. FSM (The Level Selector)
    game_state fsm (
        .clk(clk),
        .level_sw(SW[2:0]),
        .all_flags(all_collected),
        .time_out(time_out),
        .game_active(game_active),
        .level_id(current_level),
        .state_out(game_state)
    );

    // 3. Player Movement
    controller control (
        .clk(clk),
        .rst(~game_active),
		  .level_id(current_level),
        .btn_u(~KEY[3]),
        .btn_d(~KEY[2]),
        .btn_l(~KEY[1]),
        .btn_r(~KEY[0]),
        .player_x(p_x),
        .player_y(p_y)
    );

    // 4. Map Logic
    map maps (
        .xPixel(xPixel),
        .yPixel(yPixel),
        .level_id(current_level),
        .is_wall(pixel_wall)
    );
	 
	 // 5. Flag Logic
	 flag flags (
        .clk(clk),
        .rst(~game_active),
        .level_id(current_level),
        .player_x(p_x),
        .player_y(p_y),
        .vga_x(xPixel),
        .vga_y(yPixel),
        .flag_pixel(pixel_flag),
        .all_collected(all_collected)
    );
	 
	 fuel fuel_timer (
		  .clk(clk),
		  .rst(~game_active),
		  .time_out(time_out),
		  .fuel_width(fuel_width)
	 );

    // 6. VGA Driver
    vga_driver vga (
        .clk(clk),
        .rst(1'b1), // Driver always active
        .vga_clk(VGA_CLK),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .active_pixels(active_pixels),
        .xPixel(xPixel),
        .yPixel(yPixel),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N)
    );

    // 6. Color Logic
    always @(*) begin
        if (!active_pixels) begin
            {VGA_R, VGA_G, VGA_B} = 24'h000000;
        end else begin
            case (game_state)
                // IDLE (Blue Title Screen)
                2'b00: begin
						{VGA_R, VGA_G, VGA_B} = 24'h7F00FE;
					 
						// Write "RALLY_DE1" in white
						// Vertical size constraint
						if (yPixel >= 10'd215 && yPixel <= 10'd265) begin
						
							// Each character is 30 pixels wide with a 10 pixel gap between
							// (30*9)+(10*8)=350, 640-350=290, 290/2=145
							// Start first letter 145 pixels from left
							// LETTER R (x: 145-175)
							if ((xPixel >= 145 && xPixel <= 150) || // Left Vertical
								 (xPixel >= 145 && xPixel <= 175 && yPixel <= 220) || // Top
								 (xPixel >= 145 && xPixel <= 175 && yPixel >= 235 && yPixel <= 240) || // Middle
								 (xPixel >= 170 && xPixel <= 175 && yPixel <= 240) || // Right Top
								 (xPixel >= 165 && xPixel <= 170 && yPixel >= 240 && xPixel >= 160)) // Right Leg
								 {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;

							// LETTER A (x: 185-215)
							else if ((xPixel >= 185 && xPixel <= 190) || // Left Vertical
										(xPixel >= 210 && xPixel <= 215) || // Right Vertical
										(xPixel >= 185 && xPixel <= 215 && yPixel <= 220) || // Top
										(xPixel >= 185 && xPixel <= 215 && yPixel >= 235 && yPixel <= 240)) // Middle
								 {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;

							// LETTER L (x: 225-255)
							else if ((xPixel >= 225 && xPixel <= 230) || // Left Vertical
										(xPixel >= 225 && xPixel <= 255 && yPixel >= 260)) // Bottom
								 {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;

							// LETTER L (x: 265-295)
							else if ((xPixel >= 265 && xPixel <= 270) || // Left Vertical
										(xPixel >= 265 && xPixel <= 295 && yPixel >= 260)) // Bottom
								 {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;

							// LETTER Y (x: 305-335)
							else if ((xPixel >= 305 && xPixel <= 310 && yPixel <= 240) || // Left Top
										(xPixel >= 330 && xPixel <= 335 && yPixel <= 240) || // Right Top
										(xPixel >= 305 && xPixel <= 335 && yPixel >= 235 && yPixel <= 240) || // Middle
										(xPixel >= 317 && xPixel <= 322 && yPixel >= 240)) // Bottom
								 {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;

							// UNDERSCORE (x: 345-375)
							else if (xPixel >= 345 && xPixel <= 375 && yPixel >= 260) // Bottom
								 {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;

							// LETTER D (x: 385-415)
							else if ((xPixel >= 385 && xPixel <= 390) || // Left Vertical
										(xPixel >= 410 && xPixel <= 415 && yPixel >= 220 && yPixel <= 260) || // Right Vertical
										(xPixel >= 385 && xPixel <= 410 && yPixel <= 220) || // Top
										(xPixel >= 385 && xPixel <= 410 && yPixel >= 260)) // Bottom
								 {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;

							// LETTER E (x: 425-455)
							else if ((xPixel >= 425 && xPixel <= 430) || // Left Vertical
										(xPixel >= 425 && xPixel <= 455 && yPixel <= 220) || // Top
										(xPixel >= 425 && xPixel <= 450 && yPixel >= 235 && yPixel <= 240) || // Middle
										(xPixel >= 425 && xPixel <= 455 && yPixel >= 260)) // Bottom
								 {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;

							// NUMBER 1 (x: 465-495)
							else if ((xPixel >= 477 && xPixel <= 482) || // Center Vertical
										(xPixel >= 470 && xPixel <= 482 && yPixel <= 220) || // Top
										(xPixel >= 465 && xPixel <= 495 && yPixel >= 260)) // Bottom
								 {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;
						end
					 end
						 
                // PLAY
                2'b01: begin
						  if (xPixel >= 10'd512 && yPixel >= 10'd416) begin
								{VGA_R, VGA_G, VGA_B} = 24'h000000;
								// Yellow Fuel Bar
								if (yPixel >= 10'd448 && yPixel <= 10'd468 && xPixel >= 528 && xPixel < (528 + fuel_width))
                             {VGA_R, VGA_G, VGA_B} = 24'hFFFF00;
								// Red Ticks
								else if (yPixel >= 10'd442 && yPixel <= 10'd446 && (xPixel >= 10'd528 && xPixel <= 10'd530
												| xPixel >= 10'd575 && xPixel <= 10'd577 | xPixel >= 10'd622 && xPixel <= 10'd624))
									  {VGA_R, VGA_G, VGA_B} = 24'hFF0000;
								// Yellow Ticks
								else if (yPixel >= 10'd444 && yPixel <= 10'd446 && (xPixel >= 10'd540 && xPixel <= 10'd542
												| xPixel >= 10'd552 && xPixel <= 10'd554 | xPixel >= 10'd564 && xPixel <= 10'd566
												| xPixel >= 10'd588 && xPixel <= 10'd590 | xPixel >= 10'd600 && xPixel <= 10'd602
												| xPixel >= 10'd612 && xPixel <= 10'd614))
									  {VGA_R, VGA_G, VGA_B} = 24'hFFFF00;
									  
                        // Write "FUEL" in green
                        // Vertical location / size constraint
                        else if (yPixel >= 10'd420 && yPixel <= 10'd435) begin
								
                             // Letter F (x: 547-557)
                             if ((xPixel >= 547 && xPixel <= 549) || // Left Vertical
                                 (xPixel >= 547 && xPixel <= 557 && yPixel <= 422) || // Top
                                 (xPixel >= 547 && xPixel <= 555 && yPixel >= 426 && yPixel <= 428)) // Middle
                                 {VGA_R, VGA_G, VGA_B} = 24'h40FF40;

                             // Letter U (x: 562-572)
                             else if ((xPixel >= 562 && xPixel <= 564) || // Left Vertical
                                      (xPixel >= 570 && xPixel <= 572) || // Right Vertical
                                      (xPixel >= 562 && xPixel <= 572 && yPixel >= 433)) // Bottom
                                 {VGA_R, VGA_G, VGA_B} = 24'h40FF40;

                             // Letter E (x: 580-590)
                             else if ((xPixel >= 580 && xPixel <= 582) || // Left Vertical
                                      (xPixel >= 580 && xPixel <= 590 && (yPixel <= 422 || yPixel >= 433)) || // Top / Bottom
                                      (xPixel >= 580 && xPixel <= 588 && yPixel >= 426 && yPixel <= 428)) // Middle
                                 {VGA_R, VGA_G, VGA_B} = 24'h40FF40;

                             // Letter L (x: 595-605)
                             else if ((xPixel >= 595 && xPixel <= 597) || // Left Vertical
                                      (xPixel >= 595 && xPixel <= 605 && yPixel >= 433)) // Bottom
                                 {VGA_R, VGA_G, VGA_B} = 24'h40FF40;
                        end
						  end
									  
                    // Draw Player (Purple)
                    else if ((xPixel >= p_x && xPixel < p_x + 32) && 
                        (yPixel >= p_y && yPixel < p_y + 32)) 
                        {VGA_R, VGA_G, VGA_B} = 24'h7F00FE;
                    
                    // Draw Walls
                    else if (pixel_wall) begin
								// Red
								if ((gx % 2 == 1 && gy % 2 == 1) || (gx % 2 == 0 && gy % 2 == 0))
									  {VGA_R, VGA_G, VGA_B} = 24'hFF0000;
								// White
								else
									  {VGA_R, VGA_G, VGA_B} = 24'hFFFFFF;
						  end

                    // Draw Flag (Yellow)
                    else if (pixel_flag) 
                        {VGA_R, VGA_G, VGA_B} = 24'hFFFF00;
                        
                    // Draw Floor (Gray)
                    else 
                        {VGA_R, VGA_G, VGA_B} = 24'h404040;
                end
                
                // WIN (Green)
                2'b10: {VGA_R, VGA_G, VGA_B} = 24'h00FF00;

                // LOSE (Red)
                2'b11: {VGA_R, VGA_G, VGA_B} = 24'hFF0000;
                
                // Default (Cyan - Error State)
                default: {VGA_R, VGA_G, VGA_B} = 24'h00FFFF;
            endcase
        end
    end

endmodule