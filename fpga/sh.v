`timescale 1ns / 1ps

module sh(
    input clk,                // 100MHz clock
    input reset,              // BTN-C reset
    input [2:0] id_bits,      // ID from switches
    input [1:0] data_bits,    // Data from switches
    input error_inject,       // Error injector (switch)
    output reg can_out,       // Output to RX or loopback
    output reg tx_led,        // Transmission LED
    output wire [6:0] seg,    // Seven segment
    output wire [3:0] an      // Anode control
);

    // Registers for CAN frame transmission
 
    reg [6:0] frame;
    reg [2:0] bit_counter;
    reg [26:0] clk_divider;  
    reg [4:0] prev_data;

    wire [4:0] curr_data = {id_bits, data_bits};
    wire checksum = data_bits[1] ^ data_bits[0];

    parameter CLK_DIV_MAX = 250_000; // ~2.5ms per bit

    // Registers to control 7-seg HOLD behavior

    reg [2:0] id_reg;
    reg [1:0] data_reg;

    reg [2:0] last_id;
    reg [1:0] last_data;

    // Error latch registers (fix)
    
    reg error_reg;    // internal latched error shown on display
    reg last_error;   // last sampled external error state

    // MAIN LOGIC

    always @(posedge clk) begin
        if (reset) begin
            // Transmission reset
            frame <= 0;
            bit_counter <= 0;
            clk_divider <= 0;
            can_out <= 1;
            tx_led <= 0;
            prev_data <= 0;

            // DISPLAY RESET (keeps 00 after release)
            id_reg   <= 3'b000;
            data_reg <= 2'b00;

            // Store switch values so display does NOT return to old value
            last_id   <= id_bits;
            last_data <= data_bits;

            // CLEAR internal error on reset and sample external state
            error_reg  <= 1'b0;
            last_error <= error_inject;

        end else begin

          
            // Update displayed id/data ONLY WHEN SWITCHES CHANGE
  
            if (id_bits != last_id || data_bits != last_data) begin
                id_reg   <= id_bits;
                data_reg <= data_bits;

                last_id   <= id_bits;
                last_data <= data_bits;
            end

            // Update latched error only when external error toggles
            // (this prevents holding the external switch from overriding reset)
            
            if (error_inject != last_error) begin
                error_reg  <= error_inject;
                last_error <= error_inject;
            end

            // CAN Frame Transmission Logic (unchanged)
            
            clk_divider <= clk_divider + 1;
            if (clk_divider == CLK_DIV_MAX) begin
                clk_divider <= 0;

                if (curr_data != prev_data) begin
                    frame[6] <= 1'b0;                     // Start bit
                    frame[5:3] <= id_bits;                // ID
                    frame[2:1] <= data_bits;              // DATA
                    frame[0] <= error_inject ? ~checksum : checksum; // Checksum
                    
                    bit_counter <= 7;
                    prev_data <= curr_data;

                    tx_led <= 1;
                end else if (bit_counter > 0) begin
                    can_out <= frame[6];
                    frame <= {frame[5:0], 1'b1};
                    bit_counter <= bit_counter - 1;

                    if (bit_counter == 1)
                        tx_led <= 0;
                end
            end
        end
    end

    // 7-SEGMENT MODULE INSTANCE (pass latched error)
    
    // Note: display uses id_reg/data_reg, and error_flag is internal error_reg.
    sevenseg_display u7seg (
        .clk(clk),
        .reset(reset),
        .rx_id(id_reg),
        .rx_data(data_reg),
        .error_flag(error_reg),   // <--- important: use latched/cleared error_reg
        .seg(seg),
        .an(an)
    );

endmodule

// 7 SEGMENT DISPLAY MODULE (reset has highest priority)

module sevenseg_display(
    input clk,
    input reset,
    input [2:0] rx_id,
    input [1:0] rx_data,
    input error_flag,
    output reg [6:0] seg,
    output reg [3:0] an
);

    reg [1:0] digit_sel;
    reg [3:0] value;
    reg [15:0] refresh_counter;

    // free-running refresh counter
    always @(posedge clk) begin
        if (reset) begin
            refresh_counter <= 0;
            digit_sel <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
            digit_sel <= refresh_counter[15:14];
        end
    end

    // value selection with explicit reset priority per-digit
    always @(*) begin
        case (digit_sel)
            2'b00: begin // rightmost digit (data)
                if (reset) value = 4'h0;
                else if (error_flag) value = 4'hE;
                else value = {2'b00, rx_data}; // map 2-bit data to 0..3
            end
            2'b01: begin // next digit (id)
                if (reset) value = 4'h0;
                else if (error_flag) value = 4'hE;
                else value = rx_id; // 3-bit id fits 0..7
            end
            default: value = 4'hF;
        endcase
    end

    // anode control (normal multiplex)
    always @(*) begin
        case (digit_sel)
            2'b00: an = 4'b1110;
            2'b01: an = 4'b1101;
            default: an = 4'b1111;
        endcase
    end

    // hex -> 7-seg (common cathode mapping)
    always @(*) begin
        case (value)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hE: seg = 7'b0000110; // E
            default: seg = 7'b1111111; // blank
        endcase
    end
end module