
`include "export/lcd_driver.v"

module top(
  output [2:0] rgb,
  output [7:0] lcd_d,
  output lcd_rs,
  output lcd_wr_n,
  output lcd_cs_n,
  output lcd_rst_n,
  input  lcd_mode,
  input  lcd_fmark,
  input  clk_in
  );

reg ready = 0;
reg [15:0] RST_d;
reg [15:0] RST_q;
wire reset = ~RST_q[15];

always @* begin
  RST_d = RST_q[15] ? RST_q : RST_q + 1;
end

always @(posedge clk_in) begin
  if (ready) begin
    RST_q <= RST_d;
  end else begin
    ready <= 1;
    RST_q <= 0;
  end
end

// Using current-limited outputs, see note here:
// https://github.com/badgeteam/mch2022-firmware-ice40/blob/43c77cfc5e1fd4599ca16852cd9c087b396fc651/projects/Fading-RGB/rtl/fading_rgb.v#L20-L29

SB_RGBA_DRV #(
      .CURRENT_MODE("0b1"),       // half current
      .RGB0_CURRENT("0b000011"),  // 4 mA
      .RGB1_CURRENT("0b000011"),  // 4 mA
      .RGB2_CURRENT("0b000011")   // 4 mA
) RGBA_DRIVER (
      .CURREN(1'b1),
      .RGBLEDEN(1'b1),
      .RGB1PWM(__main_leds[0]),
      .RGB2PWM(__main_leds[1]),
      .RGB0PWM(__main_leds[2]),
      .RGB0(rgb[0]),
      .RGB1(rgb[1]),
      .RGB2(rgb[2])
);

// Instantiates the LCD driver exported from Silice

wire      w_lcd_ready;
reg       lcd_valid;
reg [7:0] lcd_data;
reg [0:0] lcd_second_byte = 0;

M_lcd_driver lcd (
.in_valid(lcd_valid),    // high to send (one byte per clock)
.in_data(lcd_data),      // data to be sent
.out_ready(w_lcd_ready), // high when ready (does not go low after)
.in_lcd_mode(lcd_mode),
.in_lcd_fmark(lcd_fmark),
.out_lcd_d(lcd_d),
.out_lcd_rs(lcd_rs),
.out_lcd_wr_n(lcd_wr_n),
.out_lcd_cs_n(lcd_cs_n),
.out_lcd_rst_n(lcd_rst_n),
.reset(reset),
.clock(clk_in));

reg [8:0] x = 0; // up to 320
reg [7:0] y = 0; // up to 240

wire [4:0] r = x[1+:5];
wire [5:0] g = y[0+:6];
wire [4:0] b = 5'b0;
wire [15:0] rgb565 = {g[0+:3],r,b,g[3+:3]};

always @(posedge clk_in) begin
  // produces x,y screen coords, y increments first (column by column)
  x               <= (lcd_second_byte || y != 239)
                   ? x
                   : ((x == 319 || ~w_lcd_ready) ? 0 : x + 1);
  y               <= lcd_second_byte
                   ? y
                   : ((y == 239 || ~w_lcd_ready) ? 0 : y + 1);
  lcd_data        <= lcd_second_byte ? rgb565[0+:8] : rgb565[8+:8];
  lcd_valid       <= w_lcd_ready;
  lcd_second_byte <= lcd_valid & ~lcd_second_byte;

end


endmodule
