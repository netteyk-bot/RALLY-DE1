module game_state (
    input clk,
    input [2:0] level_sw,
    input all_flags,
    input time_out, 

    output reg game_active,
    output reg [1:0] level_id, 
    output reg [1:0] state_out
);

    parameter S_IDLE = 2'b00;
    parameter S_PLAY = 2'b01;
    parameter S_WIN  = 2'b10;
    parameter S_LOSE = 2'b11;

    reg [1:0] S = S_IDLE; 
    reg [1:0] NS;

    // No master reset
    always @(posedge clk) begin
        S <= NS;
    end

    // 2. Next State Logic
    always @(*) begin
        // Defaults
        NS = S;
        level_id = 2'b00; 
        state_out = S;
        game_active = 1'b0; 

        case (S)
            S_IDLE: begin
                game_active = 1'b0;
                
					 // Level 1
                if (level_sw[0]) begin
                    NS = S_PLAY;
                    level_id = 2'd1;
                end
					 // Level 2
                else if (level_sw[1]) begin
                    NS = S_PLAY;
                    level_id = 2'd2;
                end
					 // Level 3
                else if (level_sw[2]) begin
                    NS = S_PLAY;
                    level_id = 2'd3;
                end
            end

            S_PLAY: begin
                game_active = 1'b1;
                
                // Set Level ID
                if (level_sw[0])
						  level_id = 2'd1;
                else if (level_sw[1])
						  level_id = 2'd2;
					 else if (level_sw[2])
						  level_id = 2'd3;
                
                // State Transitions
                if (level_sw == 2'b00)
						  NS = S_IDLE;
                else if (all_flags)
						  NS = S_WIN;
                else if (time_out)
						  NS = S_LOSE;
					 else
						  NS = S_PLAY;
            end

            S_WIN: begin
                game_active = 1'b0;
                if (level_sw == 2'b00)
						  NS = S_IDLE;
					else
						  NS = S_WIN;
            end

            S_LOSE: begin
                game_active = 1'b0;
                if (level_sw == 2'b00)
						  NS = S_IDLE;
					 else
						  NS = S_LOSE;
            end
            
            default: begin
                game_active = 1'b0;
                NS = S_IDLE;
            end
        endcase
    end
endmodule