// This is directly derived from the button example in:
//   https://github.com/badgeteam/mch2022-firmware-ice40/blob/master/projects/Buttons/rtl/buttons.v
// The main building blocks are provided in the badge respository:
//   https://github.com/badgeteam/mch2022-firmware-ice40

module spi_buttons(
    // pins
    input  spi_mosi,   output spi_miso,
    input  spi_cs_n,   input  spi_clk,
    output irq_n,
    input  clk,        input  resetq,
    // outputs
    output joystick_down,
    output joystick_up,
    output joystick_left,
    output joystick_right,
    output joystick_press,
    output home,
    output menu,
    output select,
    output start,
    output accept,
    output back
);

    // -----------------------------------------------
    // SPI interface
    // -----------------------------------------------

    wire [7:0] usr_miso_data, usr_mosi_data;
    wire usr_mosi_stb, usr_miso_ack;
    wire csn_state, csn_rise, csn_fall;

    spi_dev_core _communication (

        .clk (clk),
        .rst (resetq),

        .usr_mosi_data (usr_mosi_data),
        .usr_mosi_stb  (usr_mosi_stb),
        .usr_miso_data (usr_miso_data),
        .usr_miso_ack  (usr_miso_ack),

        .csn_state (csn_state),
        .csn_rise  (csn_rise),
        .csn_fall  (csn_fall),

        // Interface to SPI wires

        .spi_miso (spi_miso),
        .spi_mosi (spi_mosi),
        .spi_clk  (spi_clk),
        .spi_cs_n (spi_cs_n)
    );

    wire [7:0] pw_wdata;
    wire pw_wcmd, pw_wstb, pw_end;

    spi_dev_proto #( .NO_RESP(1)
      ) _protocol (
        .clk (clk),
        .rst (resetq),

        // Connection to the actual SPI module:

        .usr_mosi_data (usr_mosi_data),
        .usr_mosi_stb  (usr_mosi_stb),
        .usr_miso_data (usr_miso_data),
        .usr_miso_ack  (usr_miso_ack),

        .csn_state (csn_state),
        .csn_rise  (csn_rise),
        .csn_fall  (csn_fall),

        // These wires deliver received data:

        .pw_wdata (pw_wdata),
        .pw_wcmd  (pw_wcmd),
        .pw_wstb  (pw_wstb),
        .pw_end   (pw_end),

    );

  reg  [7:0] command;
  reg [31:0] incoming_data;
  reg [31:0] buttonstate;

  always @(posedge clk)
  begin
    if (pw_wstb & pw_wcmd)           command       <= pw_wdata;
    if (pw_wstb)                     incoming_data <= incoming_data << 8 | pw_wdata;
    if (pw_end & (command == 8'hF4)) buttonstate   <= incoming_data;
  end

  assign joystick_down  = buttonstate[16];
  assign joystick_up    = buttonstate[17];
  assign joystick_left  = buttonstate[18];
  assign joystick_right = buttonstate[19];
  assign joystick_press = buttonstate[20];
  assign home           = buttonstate[21];
  assign menu           = buttonstate[22];
  assign select         = buttonstate[23];

  assign start          = buttonstate[24];
  assign accept         = buttonstate[25];
  assign back           = buttonstate[26];

  /*
Bits are mapped to the following keys:
 0 - joystick down
 1 - joystick up
 2 - joystick left
 3 - joystick right
 4 - joystick press
 5 - home
 6 - menu
 7 - select
 8 - start
 9 - accept
10 - back
  */

endmodule
