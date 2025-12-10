module fuel (
    input clk,
    input rst,
	 
    output reg time_out,   // Goes high when fuel is 0
    output reg [6:0] fuel_width // 96 pixels max 
);

    // 50MHz clock. 
    // To last approx 24 seconds:
    // 24 seconds / 96 pixels = 0.25 seconds per pixel.
    // 0.25s * 50,000,000 = 12,500,000 ticks per pixel decrement.
	 // log(12,500,500) / log(2) = 24 bits

    reg [23:0] tick_count;
    
    always @(posedge clk) begin
        if (rst) begin
            fuel_width <= 7'd96; // Start full
            tick_count <= 24'd0;
            time_out <= 1'b0;
        end 
        else if (fuel_width > 0) begin
            tick_count <= tick_count + 1;
            
            // Decrement fuel every 0.25 seconds
            if (tick_count >= 24'd12500000) begin
                tick_count <= 24'd0;
                fuel_width <= fuel_width - 1;
            end
        end 
        else begin
            // Fuel is 0
            time_out <= 1'b1;
        end
    end

endmodule